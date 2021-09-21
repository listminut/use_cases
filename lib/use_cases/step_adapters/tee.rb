# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Tee < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        super(*args)
        result = previous_step_result.value
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        Success(result)
      end
    end
  end
end
