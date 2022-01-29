class TestSubscriber < UseCases::Events::Subscriber
  def on_events_step_success(_); end

  def on_events_try_failure(_); end
end
