# frozen_string_literal: true

class ExternalOperation < UseCases::Base
  params {}

  step :step_that_succeeds

  private

  def step_that_succeeds
    Success("the external operation succeeds!")
  end
end
