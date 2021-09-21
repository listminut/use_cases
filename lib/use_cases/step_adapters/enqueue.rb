# frozen_string_literal: true

module UseCases
  module StepAdapters
    class Enqueue < Abstract
      def do_call(*args)
        args = [object.class.name, name.to_s, *args]
        args = serialize_step_arguments(args)

        job_options = options.slice(:queue, :wait, :wait_until, :priority)

        ProcessStepJob.set(job_options).perform_later(*args)
      end

      def serialize_step_arguments(args)
        args.select.with_index do |arg, index|
          ActiveJob::Arguments.send(:serialize_argument, arg)

        rescue ActiveJob::SerializationError => _e
          arg.serialize.merge("_serialized_by_use_case" => true)

        rescue NoMethodError => _e
          puts "[WARNING] #{arg.class} (index = #{index})" \
               "is not serializable and does not repond to #serialize and will be ignored."
          false
        end
      end

      class ProcessStepJob < ActiveJob::Base
        def perform(use_case_name, step_name, *args)
          args = deserialize_step_arguments(args)

          use_case_name.constantize.new.send(step_name, *args)
        end

        def deserialize_step_arguments(args)
          args.map { |arg| arg.delete("_serialized_by_use_case") ? arg.deserialize : arg }
        end
      end
    end
  end
end
