# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "dry/monads/do/all"
require "dry/matcher/result_matcher"

require "use_cases/dsl"
require "use_cases/stack"
require "use_cases/params"
require "use_cases/stack_runner"
require "use_cases/result"
require "use_cases/step_adapters"
require "use_cases/module_optins"

module UseCase
  extend UseCases::DSL
  extend UseCases::ModuleOptins

  def self.included(base)
    super
    base.class_eval do
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
      include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

      extend UseCases::DSL
      extend UseCases::ModuleOptins

      include UseCases::StepAdapters
    end
  end

  attr_reader :stack

  def initialize(*)
    @stack = UseCases::Stack.new(self.class.__steps__).bind(self)
  end

  def call(params, current_user = nil)
    params = UseCases::Params.new(params)
    do_call(params, current_user)
  end

  private

  def do_call(*args)
    byebug
    UseCases::StackRunner.new(stack).call(*args)
  end
end
