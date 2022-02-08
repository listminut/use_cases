require "dry/events/publisher"

module UseCases
  module Events
    class Publisher
      include Dry::Events::Publisher[:use_cases]

      def subscribe_and_publish_event(event_name, payload)
        subscribe_to_event(event_name)
        publish(event_name, payload)
      end

      private

      def publish_async(event_name, payload)
        UseCases::Events::PublishJob.perform_later(event_name, payload)
      end

      def event_should_be_published_asynchronously?(event_name)
        defined? UseCases::Events::PublishJob && !event_name.end_with?(".async")
      end

      def subscribe_to_event(event_name)
        subscribers_for(event_name).each(&method(:subscribe))
      end

      def subscribers_for(event_name)
        available_subscribers.select do |subscriber|
          subscriber.should_subscribe_to?(event_name) && !subscribed?(subscriber)
        end
      end

      def subscribe(listener)
        subcribers << listener
        super
      end

      def subscribed?(listener)
        subcribers.include?(listener)
      end

      def subcribers
        @subcribers ||= []
      end

      def available_subscribers
        UseCases.subscribers
      end
    end
  end
end
