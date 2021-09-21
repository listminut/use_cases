# frozen_string_literal: true

class EnqueueTestUseCase < UseCases::Base
  params {}

  enqueue :some_task_to_be_performed_async

  private

  def some_task_to_be_performed_async(_previous_input, _params, _user)
    "resource loaded before authorizing"
  end
end
