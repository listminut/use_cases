# frozen_string_literal: true

module UseCases
  module Events
    class EventRegistry
      def self.register(event_id)
        event_ids << event_id
        listener_name = ["on", event_id].join("_").gsub(".", "_")
        UseCases.publisher.register_event(event_id)

        UseCases.subscribers.each do |subscriber|
          next if !subscriber.respond_to?(listener_name) || UseCases.publisher.subscribed?(subscriber.method(listener_name))

          UseCases.publisher.subscribe(subscriber)
        end
      end

      def self.event_ids
        @event_ids ||= []
      end
    end
  end
end
