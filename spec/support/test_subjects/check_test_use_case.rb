# frozen_string_literal: true

class CheckTestUseCase < UseCases::Base
  step :something_before_the_check

  check :user_admin?, failure: :user_not_admin, failure_message: "User not admin"

  private

  def something_before_the_check
    Success("it succeeds!")
  end

  def user_admin?(_previous_input, _params, user)
    user.admin?
  end
end
