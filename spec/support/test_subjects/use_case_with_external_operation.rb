# frozen_string_literal: true

class UseCaseWithExternalOperation < UseCases::Base
  params {}

  step :external_operation, with: ExternalOperation.new

  check :validate_external_operation

  private

  def validate_external_operation(external_operation_input)
    external_operation_input == "the external operation succeeds!"
  end
end
