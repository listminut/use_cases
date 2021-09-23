# frozen_string_literal: true

require "use_cases/transaction"

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
      include_transaction = option?(:transactional)

      base.class_eval do
        include UseCases::Transaction if include_transaction
      end

      reset_options!
    end

    def reset_options!
      @options = []
    end
  end
end
