# frozen_string_literal: true

class ValidateTestUseCase < UseCases::Base
  params do
    required(:required_string_param).filled(:string)
    required(:value_checked_param).value(eql?: "some string")
  end
end
