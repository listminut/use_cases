# frozen_string_literal: true

require "use_cases/events/publisher"
require "use_cases/events/subscriber"
require "use_cases/events/publish_job"
require "use_cases/events/event_registry"

module UseCases
  module ModuleOptins
    module Publishing
      def self.included(base)
        super
        StepAdapters::Abstract.prepend StepPatch
      end

      module StepPatch
        def initialize(*)
          super
          return unless options[:publish]

          %w[success failure].map do |event_type|
            event_id = [options[:publish], event_type].join(".")
            Events::EventRegistry.register(event_id)
          end
        end

        def call(*args)
          super(*args).tap do |result|
            publish_step_result(result, args)
          end
        end

        def publish_step_result(step_result, args)
          return unless options[:publish]

          key = extract_event_key(step_result)
          payload = extract_payload(step_result, args)

          UseCases.publisher.publish(key, payload)
        end

        private

        def extract_payload(step_result, args)
          {
            return_value: step_result.value!,
            params: args[-2],
            current_user: args[-1]
          }
        end

        def extract_event_key(step_result)
          options[:publish].to_s + (step_result.success? ? ".success" : ".failure")
        end
      end
    end
  end
end
