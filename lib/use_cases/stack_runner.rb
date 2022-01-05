# frozen_string_literal: true

module UseCases
  class StackRunner
    attr_reader :stack

    def initialize(stack)
      @stack = stack
    end

    def call(*args)
      do_call(*args)
    end

    private

    def do_call(*args)
      stack.call do
        result = _run_step(stack, args)
        args.last.call(result, stack.current_step) if args.last.is_a? Proc

        return result if result.failure?

        result
      end
    end

    def _run_step(stack, args)
      step = stack.current_step
      step_args = _assert_step_arguments(stack, args)

      raise MissingStepError, "Missing ##{step.name} implementation." if step.missing?

      step.call(*step_args)
    end

    def _assert_step_arguments(stack, args)
      if _should_prepend_previous_step_result_to_args?(stack)
        prev_step_result_value = stack.previous_step_value

        args = [prev_step_result_value] + args
      end

      args
    end

    def _should_prepend_previous_step_result_to_args?(stack)
      !stack.previous_result_empty? && !stack.in_first_step?
    end
  end
end
