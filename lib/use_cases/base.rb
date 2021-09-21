# frozen_string_literal: true

require "dry/monads"
require "dry/events"
require "dry/monads/do"
require "dry/monads/do/all"
require "dry/matcher/result_matcher"
require "active_support/hash_with_indifferent_access"

require "use_cases/authorize"
require "use_cases/dsl"
require "use_cases/errors"
require "use_cases/validate"
require "use_cases/stack"
require "use_cases/stack_runner"
require "use_cases/step_result"
require "use_cases/notifications"

module UseCases
  class Base
    def self.inherited(base)
      super

      base.class_eval do
        extend DSL

        include Dry::Monads[:result, :try]
        include Dry::Monads::Do.for(:call)
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        include UseCases::Notifications
        include UseCases::Validate
        include UseCases::Authorize
      end
    end

    attr_reader :stack

    def initialize(*)
      @stack = Stack.new(self.class.__steps__)
      # self.class.bind_step_subscriptions
    end

    def call(params, current_user = nil)
      stack.bind(self)

      params = transform_params(params)

      StackRunner.new(stack).call(params, current_user)
    end

    def transform_params(params)
      if defined?(Rails) && params.is_a?(ActionController::Parameters)
        ActiveSupport::HashWithIndifferentAccess.new(params.permit!.to_h)
      else
        ActiveSupport::HashWithIndifferentAccess.new(params)
      end
    end
  end
end
