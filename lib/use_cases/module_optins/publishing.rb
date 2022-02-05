# frozen_string_literal: true

require "use_cases/events/publisher"
require "use_cases/events/subscriber"
require "use_cases/events/publish_job"

module UseCases
  module ModuleOptins
    module Publishing
      def self.included(base)
        super
        StepAdapters::Abstract.prepend StepPatch
      end

      module StepPatch
        def initialize(*args)
          super
          return unless options[:publish] && UseCases.publisher

          register_events
        end

        def register_events
          event_names.each do |event_name|
            next if UseCases.publisher.class.events[event_name]

            UseCases.publisher.class.register_event(event_name)
          end
        end

        def event_names
          event_name = options[:publish]
          [
            "#{event_name}.success", "#{event_name}.failure",
            "#{event_name}.success.async", "#{event_name}.failure.async"
          ]
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

          UseCases.publisher.subscribe_and_publish_event(key, payload)
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
