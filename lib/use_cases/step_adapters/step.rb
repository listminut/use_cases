# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Step < UseCases::StepAdapters::Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        raise InvalidReturnValue, "Return value should be a Monad" unless result.is_a?(Dry::Monads::Result)

        result
      end
    end
  end
end
