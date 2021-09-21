# frozen_string_literal: true

require "sidekiq/worker"

module UseCases
  module Steps
    class Enqueue < Abstract
      def do_call(*args)
        args = [object.class.name, name, *args]
        args = serialize_each(args)

        JobProcessor.perform_async(*args)
      end

      def serialize_each(values); end

      class JobProcessor
        include Sidekiq::Worker

        def perform(use_case, step_name, *args)
          args = deserialize_each(args)

          use_case.constantize.new.send(step_name, *args)
        end

        def deserialize_each(values); end
      end
    end
  end
end
