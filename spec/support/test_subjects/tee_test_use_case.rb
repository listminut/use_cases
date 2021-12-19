# frozen_string_literal: true

class TeeTestUseCase
  include UseCase

  step :something_done_before_tee

  tee :something_that_can_fail_and_we_dont_care

  private

  def something_done_before_tee
    Success("it succeeds!")
  end

  def something_that_can_fail_and_we_dont_care(_previous_input, _params, _user)
    "do something else that is meaningless"
  end
end
