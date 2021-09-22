# frozen_string_literal: true

class StepTestUseCase < UseCases::Base
  params {}

  step :do_something

  step :do_something_after

  def do_something(params, user); end

  def do_something_after(prev_result)
    Success("previous message: #{prev_result}")
  end
end
