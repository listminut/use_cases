# frozen_string_literal: true

require "use_cases/events/publisher"
require "use_cases/events/publish_job"

module UseCases
  module ModuleOptins
    module Publishing
      def self.included(base)
        super
        base.prepend DoCallPatch
      end

      module DoCallPatch
        def do_call(*args)
          super(*args, method(:publish_step_result).to_proc)
        end

        def publish_step_result(step_result, step_object)
          publish_key = step_object.options[:publish]
          publish_key += step_result.success? ? ".success" : ".failure"
          payload = step_result.value!
          return unless publish_key

          register_event(publish_key)
          peform_publish(publish_key, payload)
        end

        def register_event(publish_key)
          return if UseCases.publisher.class.events[publish_key]

          UseCases.publisher.class.register_event(publish_key)
        end

        def peform_publish(publish_key, payload)
          UseCases.publisher.publish(publish_key, payload)
          return unless defined? UseCases::Events::PublishJob

          UseCases::Events::PublishJob.perform_later(publish_key, payload.to_json)
        end
      end
    end
  end
end
