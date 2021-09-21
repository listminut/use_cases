# frozen_string_literal: true

require "use_cases/steps/abstract"

module UseCases
  module Steps
    class Tee < Abstract
      def do_call(*args)
        super(*args)
        Success(previous_step_result.value)
      end
    end
  end
end
