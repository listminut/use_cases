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
        def initialize(*)
          super
          finalize_subscriptions!
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


        def finalize_subscriptions!
          event_ids.each do |event_id|
            listener_name = ['on', event_id].join('_').gsub('.', '_')
            UseCases.publisher.register_event(event_id)

            UseCases.subscribers.each do |subscriber|
              next if !subscriber.respond_to?(listener_name) || UseCases.publisher.subscribed?(subscriber.method(listener_name))

              UseCases.publisher.subscribe(subscriber)
            end
          end
        end

        def event_ids
          %w[success failure success.async failure.async].map do |event_type|
            [options[:publish], event_type].join('.')
          end
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
