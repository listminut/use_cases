# frozen_string_literal: true

class EventsTestUseCase
  include UseCase[:publishing]

  map :do_something, publish: "events.step"

  try :do_something_else, publish: "events.try", failure: :failed, failure_message: "Failed"

  private

  def do_something(_params, _user)
    "result"
  end

  def do_something_else(_do_something_result, _params, _user)
    raise
  end
end
