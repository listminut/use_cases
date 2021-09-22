# frozen_string_literal: true

module UseCases
  module StepAdapters
    class Enqueue < Tee
      def do_call(*base_args)
        args = [object.class.name, name.to_s, *base_args]
        args = StepActiveJobAdapter.serialize_step_arguments(args)

        job_options = options.slice(:queue, :wait, :wait_until, :priority)

        StepActiveJobAdapter.set(job_options).perform_later(*args)

        Success(previous_step_result.value)
      end
    end
  end
end
