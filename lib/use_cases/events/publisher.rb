require "dry/events/publisher"

module UseCases
  module Events
    class Publisher
      include Dry::Events::Publisher[:use_cases]

      def self.register_and_publish_event(event_name, payload)
        register_events(event_name)

        new.tap do |publisher|
          publisher.subscribe_to_event(event_name)
          publisher.publish(event_name, payload)
        end

        return unless defined? UseCases::Events::PublishJob

        UseCases::Events::PublishJob.perform_later(event_name, payload)
      end

      def self.extract_payload(use_case_args)
        {
          return_value: use_case_args[0],
          params: use_case_args[1],
          current_user: use_case_args[2]
        }
      end

      def self.register_events(event_name)
        [event_name, "#{event_name}.aync"].each do |key|
          register_event(key) unless events[key]
        end
      end

      def subscribe_to_event(event_name)
        subscribers_for(event_name).each(&method(:subscribe))
      end

      def subscribers_for(event_name)
        available_subscribers.select do |subscriber|
          subscriber.subscribed_to?(event_name)
        end
      end

      def available_subscribers
        UseCases::Events::Subscriber.descendants.map(&:new) + UseCases.subscribers
      end
    end
  end
end
