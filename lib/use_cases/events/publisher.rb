require "dry/events/publisher"

module UseCases
  module Events
    class Publisher
      include Dry::Events::Publisher[:use_cases]

      # This is a hack waiting for this https://github.com/dry-rb/dry-events/pull/15 to be merged
      def subscribed?(listener)
        __bus__.listeners.values.any? do |value|
          value.any? do |block, _|
            block.owner == listener.owner && block.name == listener.name
          end
        end
      end
    end
  end
end
