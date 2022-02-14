# frozen_string_literal: true

module UseCases
  module Events
    module Subscriber
      def self.included(base)
        UseCases.subscribers << base.new
      end

      def should_subscribe_to?(event_name)
        event_handler_name = "on_#{event_name.gsub(".", "_")}"

        respond_to?(event_handler_name.to_sym)
      end
    end
  end
end
