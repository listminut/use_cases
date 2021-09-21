# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Try < Abstract
      def do_call(*args)
        Success(super(*args))
      rescue options[:catch] || StandardError => e
        Failure([options[:failure], e.message])
      end
    end
  end
end
