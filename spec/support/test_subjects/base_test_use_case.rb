# frozen_string_literal: true

class BaseTestUseCase < UseCases::Base
  params do
    required(:required_string_param).filled(:string)
    required(:type_checked_param).value(:string)
  end

  def admin?(_, _, user)
    user.admin?
  end

  step :do_something

  try :do_something_else

  authorize :admin?, failure_message: "User must be admin"

  private

  def do_something(validation_result, params, user); end

  def do_something_else(do_something_result, params, user); end
end
