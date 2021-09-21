require "dry/validation/contract"

module UseCases
  module Validate
    class NoValidationError < StandardError; end

    def self.included(base)
      base.class_eval do
        extend DSL
        extend ClassMethods

        step :validate
      end
    end

    module DSL
      def params(*args, &blk)
        _setup_validation unless _validation_setup?

        _contract_class.params(*args, &blk)
      end

      def schema(*args, &blk)
        _setup_validation unless _validation_setup?

        _contract_class.schema(*args, &blk)
      end

      def rule(*args, &blk)
        _setup_validation unless _validation_setup?

        _contract_class.rule(*args, &blk)
      end

      def json(*args, &blk)
        _setup_validation unless _validation_setup?

        _contract_class.json(*args, &blk)
      end

      def option(*args, &blk)
        _contract_class.option(*args, &blk)
      end
    end

    private

    def validate(params, current_user)
      return Failure([:validation_error, "*params* must be a hash."]) unless params.respond_to?(:merge)

      validation = contract.call(params.merge(current_user: current_user))

      validation.success? ? Success(validation) : Failure([:validation_error, validation.errors.to_h])
    end

    def contract
      return self.class._contract_class.new if self.class._contract_class_defined?

      raise NoValidationError,
            "Make sure to define params validations by using *params*, *schema*, *json*, *rule* or *option* macros in your use case."
    end

    module ClassMethods
      def _setup_validation
        _define_contract_class
      end

      def _validation_setup?
        _contract_class_defined?
      end

      def _contract_class
        self::Contract
      end

      def _define_contract_class
        const_set(:Contract, Class.new(Dry::Validation::Contract))
      end

      def _contract_class_name
        "#{name}::Contract"
      end

      def _contract_class_defined?
        Object.const_defined? _contract_class_name
      end
    end
  end
end
