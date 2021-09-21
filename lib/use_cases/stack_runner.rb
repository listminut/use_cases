module UseCases
  class StackRunner
    attr_reader :stack

    def initialize(stack)
      @stack = stack
    end

    def call(*args)
      stack.call do
        result = _run_step(stack, args)

        return result if result.failure?

        result
      end
    end

    private

    def _run_step(stack, args)
      step = stack.current_step
      expected_args_count = step.args_count
      step_args = _assert_step_arguments_with_count(stack, args)

      raise MissingStepError, "Missing ##{step.name} implementation." if step.missing?

      if expected_args_count != step_args.count
        raise StepArgumentError,
              "##{step.name} expects #{expected_args_count} arguments it only received #{step_args.count}, make sure your previous step Success() statement has a payload."
      end

      step.call(*step_args)
    end

    def _assert_step_arguments_with_count(stack, args)
      step_args_count = stack.current_step.args_count

      if _should_prepend_previous_step_result_to_args?(stack)
        prev_step_result_value = stack.previous_step_value

        args = [prev_step_result_value] + args
      end

      args.first(step_args_count)
    end

    def _should_prepend_previous_step_result_to_args?(stack)
      !stack.previous_result_empty? && !stack.in_first_step?
    end
  end
end
