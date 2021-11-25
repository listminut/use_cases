# frozen_string_literal: true

require "use_cases/step_adapters/check"

module UseCases
  module StepAdapters
    class Authorize < UseCases::StepAdapters::Check
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        prev_result = previous_step_result.value
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        failure_code = options[:failure] || :unauthorized
        failure_message = options[:failure_message] || "Not Authorized"

        result ? Success(prev_result) : Failure([failure_code, failure_message])
      end
    end
  end
end
