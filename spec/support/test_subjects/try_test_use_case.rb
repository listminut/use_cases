# frozen_string_literal: true

class TryTestUseCase < UseCases::Base
  SomeError = Class.new(StandardError)

  params {}

  try :do_something, failure: :failed_with_an_error, catch: TryTestUseCase::SomeError

  step :do_something_after

  def do_something(params, user); end

  def do_something_after(prev_result)
    Success("previous message: #{prev_result}")
  end
end
