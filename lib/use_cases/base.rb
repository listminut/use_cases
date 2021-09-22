# frozen_string_literal: true

require "dry/monads"
require "dry/events"
require "dry/monads/do"
require "dry/monads/do/all"
require "dry/matcher/result_matcher"

require "use_cases/authorize"
require "use_cases/dsl"
require "use_cases/errors"
require "use_cases/validate"
require "use_cases/stack"
require "use_cases/params"
require "use_cases/stack_runner"
require "use_cases/step_result"
require "use_cases/notifications"
require "use_cases/step_active_job_adapter"
require "use_cases/step_adapters/step"
require "use_cases/step_adapters/map"
require "use_cases/step_adapters/tee"
require "use_cases/step_adapters/try"
require "use_cases/step_adapters/check"
require "use_cases/step_adapters/enqueue"

module UseCases
  class Base
    extend ::UseCases::DSL
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def self.register_adapters
      register_adapter StepAdapters::Step
      register_adapter StepAdapters::Tee
      register_adapter StepAdapters::Try
      register_adapter StepAdapters::Map
      register_adapter StepAdapters::Check
      register_adapter StepAdapters::Enqueue if defined? ActiveJob
    end

    def self.inherited(base)
      super

      base.class_eval do
        register_adapters

        include UseCases::Notifications
        include UseCases::Validate
        include UseCases::Authorize
      end
    end

    attr_reader :stack

    def initialize(*)
      @stack = Stack.new(self.class.__steps__).bind(self)
      # self.class.bind_step_subscriptions
    end

    def call(params, current_user = nil)
      params = Params.new(params)
      StackRunner.new(stack).call(params, current_user)
    end
  end
end
