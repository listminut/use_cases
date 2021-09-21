# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Step < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        raise InvalidReturnValue, "Return value should be a Monad" unless result.is_a?(Dry::Monads::Result)

        result
      end
    end
  end
end
