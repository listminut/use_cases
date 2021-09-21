# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Map < Abstract
      class InvalidReturnValue < StandardError; end

      def call(*args)
        result = super(*args)
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        Success(result)
      end
    end
  end
end
