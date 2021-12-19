# frozen_string_literal: true

class MapTestUseCase
  include UseCase
  map :something_that_will_succeed_and_funnel_down_the_result

  step :the_step_that_should_receive_map_input

  private

  def something_that_will_succeed_and_funnel_down_the_result(_params, user)
    user.admin?
  end

  def the_step_that_should_receive_map_input(_previous_input)
    Success(true)
  end
end
