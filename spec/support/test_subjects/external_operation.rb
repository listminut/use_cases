# frozen_string_literal: true

class ExternalOperation
  include UseCase

  step :step_that_succeeds

  private

  def step_that_succeeds
    Success("the external operation succeeds!")
  end
end
