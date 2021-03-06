# frozen_string_literal: true

class AuthorizeTestUseCase
  include UseCase[:authorized, :prepared]

  prepare :do_nothing

  try :load_something_necessary_for_authorize

  authorize :user_admin?, failure_message: "User needs to be admin."

  private

  def do_nothing; end

  def load_something_necessary_for_authorize
    "resource loaded before authorizing"
  end

  def user_admin?(previous_value, _, user)
    user.admin?(true) && previous_value
  end

  def run_something_after_authorizing(resource_loaded_before_authorizing)
    Success("previous result: #{resource_loaded_before_authorizing}")
  end
end
