# frozen_string_literal: true

class EnqueueTestUseCase < UseCases::Base
  try :load_something_to_be_used_by_enqueue

  def load_something_to_be_used_by_enqueue
    "something to be used by enqueue"
  end

  # this has to be registered in the test to use Rails mocks
  # enqueue :some_task_to_be_performed_async

  private

  def some_task_to_be_performed_async(_previous_input, _params, _user)
    "resource loaded before authorizing"
  end
end
