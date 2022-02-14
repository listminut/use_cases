# frozen_string_literal: true

require "use_cases/step_adapters/check"

module UseCases
  module ModuleOptins
    module Authorized
      def self.included(base)
        super
        base.class_eval do
          extend DSL
        end
      end

      module DSL
        DEFAULT_OPTIONS = {
          failure: :unauthorized,
          failure_message: "Not Authorized",
          merge_input_as: :resource
        }.freeze

        def authorize(name, options = {})
          options = DEFAULT_OPTIONS.merge(options)

          check name, options
        end
      end
    end
  end
end
