require "byebug"

module UseCases
  module Notifications
    def self.included(base)
      base.extend DSL
    end

    module DSL
      def subscribe_to_step(event_id, listener)
        step_subscriptions << StepSubscription.new(event_id, listener)
      end

      def bind_step_subscriptions
        step_subscriptions.each { |subscription| subscription.bind(__steps__) }
      end

      def step_subscriptions
        @step_subscriptions ||= []
      end
    end

    class StepSubscription
      attr_reader :event_id, :listener, :steps

      def initialize(event_id, listener)
        @event_id = event_id
        @listener = listener
      end

      def bind(steps)
        @steps = steps

        step = steps.find { |s| s.name == step_name }
        step.subscribe(event_predicate, listener)
      end

      def event_predicate
        predicate = event_id.to_s.gsub(step_name.to_s, "")

        "step#{predicate}".to_sym
      end

      def step_name
        steps.map(&:name).find { |step_name| step_name.start_with?(event_id.to_s) }
      end
    end
  end
end
