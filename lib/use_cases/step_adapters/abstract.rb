# frozen_string_literal: true

require "dry/monads/all"

module UseCases
  module StepAdapters
    class Abstract
      include Dry::Monads
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
        UseCases::Result.new(self, do_call(*args))
      end

      def do_call(*args)
        args = callable_args(args)
        callable_proc.call(*args)
      end

      def bind(object)
        self.class.new(name, object, options)
      end

      def callable_args(args)
        return args unless external?

        case args_count
        when 1, 2 then args.first.merge(user: args.last)
        when 3 then args[1].merge(user: args.last, resource: args.first)
        else args
        end
      end

      def callable_proc
        callable_object.method(callable_method).to_proc
      end

      def callable_object
        case with_option
        when NilClass, FalseClass then object
        when Symbol               then object.send(with_option)
        when String               then UseCases.config.container[with_option]
        else                           with_option
        end
      end

      def callable_method
        case with_option
        when NilClass, FalseClass then name
        else                           :call
        end
      end

      def with_option
        options[:with]
      end

      def previous_input_param_name
        options[:merge_input_as] || :input
      end

      def external?
        with_option.present?
      end

      def args_count
        callable_proc.parameters.count
      end

      def missing?
        !callable_object.respond_to?(callable_method, true)
      end
    end
  end
end
