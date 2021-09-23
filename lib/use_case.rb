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
require "use_cases/prepare"
require "use_cases/step_adapters"
require "use_cases/module_optins"

module UseCase
  extend UseCases::ModuleOptins

  # rubocop:disable Metrics/MethodLength
  def self.included(base)
    base.class_eval do
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

      extend UseCases::DSL
      extend UseCases::ModuleOptins

      include UseCases::StepAdapters
      include UseCases::Notifications
      include UseCases::Validate
      include UseCases::Authorize
      include UseCases::Prepare
    end
  end
  # rubocop:enable Metrics/MethodLength

  attr_reader :stack

  def initialize(*)
    @stack = UseCases::Stack.new(self.class.__steps__).bind(self)
    # self.class.bind_step_subscriptions
  end

  def call(params, current_user = nil)
    params = UseCases::Params.new(params)
    do_call(params, current_user)
  end

  private

  def do_call(*args)
    UseCases::StackRunner.new(stack).call(*args)
  end
end
