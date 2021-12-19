
return unless defined? ActiveJob

module UseCases
  module Events
    class PublishJob < ActiveJob::Base
      def perform(publish_key, payload)
        UseCases.publisher.publish(publish_key, payload)
      end

      private

      def publisher
        UseCases.publisher
      end
    end
  end
end
