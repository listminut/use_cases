# frozen_string_literal: true

class BaseTestUseCase < UseCases::Base
  params do
    required(:required_string_param).filled(:string)
    required(:type_checked_param).value(:string)
  end

  step :do_something

  try :do_something_else

  authorize do |user, _params, _do_something_else_result|
    user.admin?
  end

  private

  def do_something(validation_result, params, user); end

  def do_something_else(do_something_result, params, user); end
end
