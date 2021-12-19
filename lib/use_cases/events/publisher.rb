require 'dry/events/publisher'

module UseCases
  module Events
    class Publisher
      include Dry::Events::Publisher[:use_cases]
    end
  end
end
