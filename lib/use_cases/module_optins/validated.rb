# frozen_string_literal: true

require "dry/validation/contract"

module UseCases
  module ModuleOptins
    module Validated
      class NoValidationError < StandardError; end

      def self.included(base)
        super
        base.class_eval do
          extend DSL
          extend ClassMethods
          prepend CallPatch
        end
      end

      module CallPatch
        def call(*args)
          unless stack.include_step?(:validate)
            raise NoValidationError,
                  "Make sure to define params validations by using *params*" \
                  "*schema*, *json*, *rule* or *option* macros in your use case."
          end

          super
        end
      end

      module DSL
        def params(*args, &blk)
          _setup_validation

          _contract_class.params(*args, &block_with_config(&blk))
        end

        def schema(*args, &blk)
          _setup_validation

          _contract_class.schema(*args, &block_with_config(&blk))
        end

        def rule(*args, &blk)
          _setup_validation

          _contract_class.rule(*args, &block_with_config(&blk))
        end

        def json(*args, &blk)
          _setup_validation

          _contract_class.json(*args, &block_with_config(&blk))
        end

        def option(*args, &blk)
          _contract_class.option(*args, &block_with_config(&blk))
        end

        def block_with_config(&blk)
          Proc.new do 
            instance_exec(&UseCases.dry_validation)
            instance_exec(&blk) 
          end
        end
      end

      private

      def validate(params, *_args)
        return Failure([:validation_error, "*params* must be a hash."]) unless params.respond_to?(:merge)

        validation = contract.call(params)

        if validation.success?
          params.merge!(validation.to_h)
          Success(validation.to_h)
        else
          Failure([:validation_error, validation.errors.to_h])
        end
      end

      def contract
        return unless self.class._contract_class_defined?

        self.class._contract_class.new
      end

      module ClassMethods
        def _setup_validation
          _define_contract_class unless _contract_class_defined?
          _define_validation_step unless _validation_step_defined?
        end

        def _define_validation_step
          step :validate
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

        def _validation_step_defined?
          __steps__.map(&:name).include?(:validate)
        end
      end
    end
  end
end
