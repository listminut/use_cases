# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Check < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        result ? Success(result) : Failure([options[:failure] || :check_failure, result])
      end
    end
  end
end
