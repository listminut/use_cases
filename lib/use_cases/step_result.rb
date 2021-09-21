# frozen_string_literal: true

module UseCases
  class StepResult
    attr_reader :step, :result

    def initialize(step, result)
      @step = step
      @result = result
    end

    def value
      return result unless result.respond_to?(:value!)

      if result.is_a?(Dry::Monads::Result::Success) && result.value! == Dry::Monads::Unit
        nil
      elsif result.is_a?(Dry::Monads::Result::Success)
        result.value!
      elsif !result.is_a?(Dry::Monads::Result::Failure) && result.value! == Dry::Monads::Unit
        nil
      else
        result
      end
    end

    def success?
      !failure?
    end

    def failure?
      value.is_a?(Dry::Monads::Result::Failure)
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
