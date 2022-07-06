# frozen_string_literal: true

class EventsTestUseCase
  include UseCase[:publishing]

  map :do_something, publish: "events.step", event_data: proc { |value| { foo: value.quuz } }, event_metadata: proc { { baz: "qux" } }

  try :do_something_else, publish: "events.try", event_data: proc { {} }, failure: :failed, failure_message: "Failed"

  private

  def do_something(_params, _user)
    OpenStruct.new(quuz: "quux")
  end

  def do_something_else(_do_something_result, _params, _user)
    raise
  end
end
