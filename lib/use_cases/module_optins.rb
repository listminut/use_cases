# frozen_string_literal: true

require "use_cases/authorize"
require "use_cases/prepare"
require "use_cases/transaction"
require "use_cases/validate"

module UseCases
  module ModuleOptins
    attr_accessor :options

    def [](*options)
      @modules = []
      @modules << UseCases::Authorize if options.include?(:authorized)
      @modules << UseCases::Transaction if options.include?(:transactional)
      @modules << UseCases::Validate if options.include?(:validated)
      @modules << UseCases::Prepare if options.include?(:prepared)
      self
    end

    def included(base)
      super
      @modules ||= []
      return if @modules.empty?

      base.include(*@modules)
    end

    def inherited(base)
      super
      @modules ||= []
      return if @modules.empty?

      base.include(*@modules)
    end

    def descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end
end
