# frozen_string_literal: true

module UseCases
  module Authorize
    class NoAuthorizationError < StandardError; end

    def self.included(base)
      base.class_eval do
        extend DSL
      end
    end

    module DSL
      def authorize(message = "User unauthorized", &blk)
        define_method(next_authorize_step_name) do |previous_result, params, current_user|
          blk.call(current_user, params, previous_result)
        end

        check next_authorize_step_name, failure: :unauthorized, failure_message: message

        @authorize_step_count += 1
      end

      def authorize_step_count
        @authorize_step_count ||= 0
      end

      def next_authorize_step_name
        :"authorize_#{authorize_step_count + 1}"
      end
    end

    private

    def authorize(*)
      raise NoAuthorizationError,
            "Make sure to define at least one *authorize* block" \
            "for your use case (e.g. use `authorize { true }` to allow all users)."
    end

    def _resolve_message(message, *args)
      message.is_a?(String) ? message : message.call(*args)
    end
  end
end
