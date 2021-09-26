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
      return result unless result.is_a?(Dry::Monads::Result)

      if !result.is_a?(Dry::Monads::Result::Failure) && result.value! == Dry::Monads::Unit
        nil
      elsif !result.is_a?(Dry::Monads::Result::Failure)
        result.value!
      else
        result
      end
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
      success? && value.success
    end

    def nil?
      value.nil?
    end

    def to_result
      value.to_result if value.is_a?(Dry::Monads::Result::Failure)

      result
    end
  end
end
