# frozen_string_literal: true

require "dry/monads/all"
require "byebug"

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

      def do_call(*initial_args)
        args = callable_args(initial_args)
        callable_proc.call(*args)
      end

      def bind(object)
        self.class.new(name, object, options)
      end

      def callable_args(args)
        return args unless external? && selects_external_args?

        hashed_args(args).slice(*options[:pass]).values
      end

      def hashed_args(args)
        case args.length
        when 0 then {}
        when 1 then args.first
        when 2 then { params: args.first, current_user: args.last }
        when 3 then { params: args.first, current_user: args.last, previous_step_result: args.last }
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

      def selects_external_args?
        options[:pass].present?
      end

      def callable_args_count
        callable_proc.parameters.count
      end

      def missing?
        !callable_object.respond_to?(callable_method, true)
      end
    end
  end
end
