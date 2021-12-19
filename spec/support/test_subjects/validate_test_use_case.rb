# frozen_string_literal: true

class ValidateTestUseCase
  include UseCase[:validated]
  params do
    required(:required_string_param).filled(:string)
    required(:value_checked_param).value(eql?: "some string")
  end
end
