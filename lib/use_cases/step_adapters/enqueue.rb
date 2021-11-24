# frozen_string_literal: true

module UseCases
  module StepAdapters
    class Enqueue < UseCases::StepAdapters::Tee
      def do_call(*base_args)
        args = [object.class.name, name.to_s, *base_args]
        args = ::UseCases::StepActiveJobAdapter.serialize_step_arguments(args)
        byebug
        job_options = options.slice(:queue, :wait, :wait_until, :priority)

        ::UseCases::StepActiveJobAdapter.set(job_options).perform_later(*args)

        Success(previous_step_result.value)
      end
    end
  end
end
