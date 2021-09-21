# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Map < Abstract
      def call(*args)
        Success(super(*args))
      end
    end
  end
end
