# frozen_string_literal: true

return unless defined? ActiveJob

module UseCases
  module Events
    class PublishJob < ActiveJob::Base
      def perform(event_id, payload)
        event_id += ".async"
        Events::EventRegistry.register(event_id)
        UseCases.publisher.publish(event_id, payload)
      end
    end
  end
end
