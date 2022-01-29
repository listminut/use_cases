# frozen_string_literal: true

require "use_cases/events/publisher"
require "use_cases/events/subscriber"
require "use_cases/events/publish_job"

module UseCases
  module ModuleOptins
    module Publishing
      def self.included(base)
        super
        StepAdapters::Abstract.prepend StepCallPatch
      end

      module StepCallPatch
        def call(*args)
          super(*args).tap do |result|
            publish_step_result(result, args)
          end
        end

        def publish_step_result(step_result, args)
          return unless options[:publish]

          key = extract_event_key(step_result)
          payload = extract_payload(step_result, args)

          UseCases.publisher.register_and_publish_event(key, payload)
        end

        private

        def extract_payload(step_result, args)
          {
            return_value: step_result.value!,
            params: args[-2],
            current_user: args[-1]
          }.transform_values(&:to_json)
        end

        def extract_event_key(step_result)
          publish_key = options[:publish].to_s
          publish_key += step_result.success? ? ".success" : ".failure"
        end
      end
    end
  end
end
