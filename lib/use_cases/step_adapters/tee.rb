# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Tee < UseCases::StepAdapters::Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        raise InvalidReturnValue, "For a tee step, a Monad will have no effect." if result.is_a?(Dry::Monads::Result)

        Success(args.first)
      end
    end
  end
end
