# frozen_string_literal: true

module UseCases
  class Result < Dry::Monads::Result
    attr_reader :step, :result

    def initialize(step, result)
      super()
      @step = step
      @result = result
    end

    def value
      return result if result_not_monad?
      return nil if result_empty?

      result.success? ? result.value! : result.failure
    end
    alias value! value

    def success?
      !failure?
    end

    def failure?
      result.is_a?(Dry::Monads::Result::Failure)
    end

    def success
      success? && value
    end

    def failure
      failure? && value
    end

    def nil?
      value.nil?
    end

    def to_result
      self
    end

    def result_empty?
      result.success? && result.value! == Dry::Monads::Unit
    end

    def result_not_monad?
      !result.is_a?(Dry::Monads::Result)
    end

    def inspect
      if failure?
        "UseCases::Result.Failure(#{value.inspect})"
      else
        "UseCases::Result.Success(#{value.inspect})"
      end
    end
  end
end
