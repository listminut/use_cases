# frozen_string_literal: true

require "use_cases/step_adapters/tee"

module UseCases
  module Prepare
    def self.included(base)
      base.class_eval do
        extend DSL
      end
    end

    module DSL
      def prepare(name, options = {})
        __steps__.unshift StepAdapters::Tee.new(name, nil, options)
      end
    end
  end
end
