# frozen_string_literal: true

module UseCases
  module StepAdapters
    class Enqueue < Abstract
      def do_call(*args)
        args = [object.class.name, name, *args]
        ProcessEnqueueStep.perform_later(*args)
      end

      class ProcessEnqueueStep < ActiveJob::Base
        def perform(use_case, step_name, *args)
          use_case.constantize.new.send(step_name, *args)
        end
      end
    end
  end
end
