# frozen_string_literal: true

class EventsTestUseCase
  include UseCase[:publishing]

  map :do_something, publish: "events.step"

  try :do_something_else, publish: "events.try", failure: :failed, failure_message: "Failed"

  private

  def do_something(params, user)
    "result"
  end

  def do_something_else(do_something_result, params, user)
    raise
  end
end
