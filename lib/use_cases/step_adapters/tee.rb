# frozen_string_literal: true

require "use_cases/step_adapters/abstract"

module UseCases
  module StepAdapters
    class Tee < UseCases::StepAdapters::Abstract
      class InvalidReturnValue < StandardError; end

      def do_call(*args)
        super(*args)
        Success(args.first)
      end
    end
  end
end
