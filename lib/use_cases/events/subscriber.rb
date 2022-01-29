require "active_support/core_ext/class/subclasses"

module UseCases
  module Events
    class Subscriber
      def subscribed_to?(event_name)
        event_handler_name = "on_#{event_name.gsub('.', '_')}"   
        
        respond_to?(event_handler_name)
      end
    end
  end
end
