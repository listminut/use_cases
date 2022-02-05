
return unless defined? ActiveJob

module UseCases
  module Events
    class PublishJob < ActiveJob::Base
      def perform(publish_key, payload)
        publish_key += ".async"
        UseCases.publisher.subscribe_and_publish_event(publish_key, payload)
      end
    end
  end
end
