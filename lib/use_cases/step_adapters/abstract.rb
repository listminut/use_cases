# frozen_string_literal: true

require "dry/monads/all"

module UseCases
  module StepAdapters
    class Abstract
      include Dry::Monads

      # include Dry::Events::Publisher[name || object_id]

      # def self.inherited(subclass)
      #   super
      #   subclass.register_event(:step)
      #   subclass.register_event(:step_succeeded)
      #   subclass.register_event(:step_failed)
      # end

      include Dry::Monads[:result]

      attr_reader :name, :object, :failure, :options

      def initialize(name, *args, **options)
        @name = name
        @object = args.first
        @options = options
      end

      def previous_step_result
        object.stack.prev_step_result
      end

      def call(*args)
        around_call(name, args: args) do
          before_call(name, args: args)

          result = StepResult.new(self, do_call(*args))

          if result.success?
            after_call_success(name, args: args, value: result.value)
          else
            after_call_failure(name, args: args, value: result.value)
          end

          result
        end
      end

      def do_call(*args)
        callable_proc.call(*args)
      end

      def bind(object)
        self.class.new(name, object, options)
      end

      def callable_proc
        callable_object.method(callable_method).to_proc
      end

      def callable_object
        case options[:with]
        when NilClass, FalseClass then object
        when String               then object.send(options[:with])
        else                           send(options[:with])
        end
      end

      def callable_method
        case options[:with]
        when NilClass, FalseClass then name
        else                           :call
        end
      end

      def external?
        options[:with].present?
      end

      def args_count
        callable_proc.parameters.count
      end

      def missing?
        !callable_object.respond_to?(callable_method, true)
      end

      def before_call(*args); end

      def after_call_success(*args); end

      def after_call_failure(*args); end

      def around_call(*_args, &blk)
        blk.call
      end
    end
  end
end
