# frozen_string_literal: true

require "use_cases/authorize"
require "use_cases/prepare"
require "use_cases/transaction"
require "use_cases/validate"

module UseCases
  module ModuleOptins
    def [](*options)
      @options = options
      self
    end

    def options
      @options
    end

    def option?(option_name)
      @options&.include?(option_name)
    end

    def inherited(base)
      super
      base.include UseCases::Authorize if option?(:authorized)
      base.include UseCases::Transaction if option?(:transactional)
      base.include UseCases::Validate if option?(:validated)
      base.include UseCases::Prepare if option?(:prepared)

      reset_options!
    end

    def reset_options!
      @options = []
    end
  end
end
