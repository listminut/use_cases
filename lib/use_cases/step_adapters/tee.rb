# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Tee < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
      rescue StandardError => _e
        raise InvalidReturnValue, "For a tee step, a Monad will have no effect." if result.is_a?(Dry::Monads::Result)

        prev_result = previous_step_result.value
        Success(prev_result)
      end
    end
  end
end
