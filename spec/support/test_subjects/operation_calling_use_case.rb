class OperationCallingUseCase
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def call
    result = yield call_operation
    Success(result)
  end

  private

  def call_operation
    operation = Operation.new
    operation.call({})
  end
end

# Path: spec/use_cases/steps/operation.rb
class Operation
  include UseCase

  step :step_1

  def step_1
    Success(:step_1)
  end
end
