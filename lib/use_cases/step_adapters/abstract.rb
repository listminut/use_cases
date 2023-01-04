# frozen_string_literal: true

require "dry/monads/all"

module UseCases
  module StepAdapters
    class Abstract
      include Dry::Monads
      include Dry::Monads[:result]

      attr_reader :name, :object, :failure, :options

      def initialize(name, *args)
        @name = name
        @object, @options = args
      end

      def previous_step_result
        object.stack.prev_step_result
      end

      def call(...)
        UseCases::Result.new(self, do_call(...))
      end

      def do_call(*initial_args)
        args = callable_args(initial_args)
        callable_proc.call(*args)
      end

      def bind(object)
        self.class.new(name, object, options)
      end

      def callable_args(args)
        if callable_args_count > args.count
          raise StepArgumentError,
                "##{step.name} expects #{expected_args_count} arguments it only received #{step_args.count}, make sure your previous step Success() statement has a payload."
        end
        return args.first(callable_args_count) unless external? && selects_external_args?

        hashed_args(args).values
      end

      def hashed_args((prev_result, params, current_user))
        {
          previous_step_result: prev_result,
          params: params,
          current_user: current_user
        }.slice(*pass_option)
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

      def pass_option
        options[:pass]
      end

      def previous_input_param_name
        options[:merge_input_as] || :input
      end

      def external?
        !with_option.nil?
      end

      def selects_external_args?
        !pass_option.nil?
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
