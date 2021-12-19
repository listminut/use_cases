# frozen_string_literal: true

class EventsTestUseCase
  include UseCase[:publishing]

  map :do_something, publish: "events.step"

  try :do_something_else, publish: "events.try"

  private

  def do_something(params, user)
    params
  end

  def do_something_else(do_something_result, params, user)
    raise
  end
end
