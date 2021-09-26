# frozen_string_literal: true

module UseCases
  class StepResult < Dry::Monads::Result
    attr_reader :step, :result

    def initialize(step, result)
      super()
      @step = step
      @result = result
    end

    def value
      return result if result_not_monad?
      return nil if result_empty?

      result.success? ? result.value! : result
    end
    alias value! value

    def success?
      !failure?
    end

    def failure?
      value.is_a?(Dry::Monads::Result::Failure)
    end

    def failure
      failure? && value.failure
    end

    def success
      success? && value
    end

    def nil?
      value.nil?
    end

    def to_result
      value.to_result if failure?

      result
    end

    def result_empty?
      result.success? && result.value! == Dry::Monads::Unit
    end

    def result_not_monad?
      !result.is_a?(Dry::Monads::Result)
    end
  end
end
