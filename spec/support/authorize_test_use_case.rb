# frozen_string_literal: true

class AuthorizeTestUseCase < UseCases::Base
  params {}

  try :load_something_necessary_for_authorize

  authorize(proc { |user| "User #{user.email} cannot perform this action" }) do |user, _params, previous_value|
    user.admin?(true) && previous_value
  end

  private

  def load_something_necessary_for_authorize
    "resource loaded before authorizing"
  end

  def run_something_after_authorizing(resource_loaded_before_authorizing)
    Success("previous result: #{resource_loaded_before_authorizing}")
  end
end
