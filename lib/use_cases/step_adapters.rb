# frozen_string_literal: true

require "use_cases/step_adapters/step"
require "use_cases/step_adapters/map"
require "use_cases/step_adapters/tee"
require "use_cases/step_adapters/try"
require "use_cases/step_adapters/check"
require "use_cases/step_adapters/enqueue"
require "use_cases/step_active_job_adapter"

module UseCases
  module StepAdapters
    def self.included(base)
      super
      base.class_eval do
        register_adapter StepAdapters::Step
        register_adapter StepAdapters::Tee
        register_adapter StepAdapters::Try
        register_adapter StepAdapters::Map
        register_adapter StepAdapters::Check

        register_adapter StepAdapters::Enqueue if defined? ActiveJob
      end
    end
  end
end
