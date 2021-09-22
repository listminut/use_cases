# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Try < Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        result = super(*args)
        raise InvalidReturnValue, "The return value should not be a Monad." if result.is_a?(Dry::Monads::Result)

        Success(result)
      rescue options[:catch] || StandardError => e
        Failure([options[:failure], e.message])
      end
    end
  end
end