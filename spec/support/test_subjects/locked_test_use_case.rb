# frozen_string_literal: true

class LockedTestUseCase
  include UseCase[:locked]

  map :do_something

  def do_something(*)
    sleep 1
  end
end
