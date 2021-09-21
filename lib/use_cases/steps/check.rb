# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Check < Abstract
      def do_call(*args)
        result = super(*args)
        result ? Success(result) : Failure([options[:failure], result])
      end
    end
  end
end
