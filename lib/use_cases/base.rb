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
require "use_cases/steps/step"
require "use_cases/steps/map"
require "use_cases/steps/tee"
require "use_cases/steps/try"
require "use_cases/steps/check"
require "use_cases/steps/enqueue"

module UseCases
  class Base
    extend ::UseCases::DSL
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def self.register_adapters
      register_adapter Steps::Step
      register_adapter Steps::Tee
      register_adapter Steps::Try
      register_adapter Steps::Map
      register_adapter Steps::Enqueue
      register_adapter Steps::Check
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
