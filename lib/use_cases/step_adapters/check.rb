# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Check < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        prev_result = previous_step_result.value
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        failure_code = options[:failure] || :check_failure
        failure_message = options[:failure_message] || "Failed"

        result ? Success(prev_result) : Failure([failure_code, failure_message])
      end
    end
  end
end
