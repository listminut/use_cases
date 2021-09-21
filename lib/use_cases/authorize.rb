module UseCases
  module Authorize
    class NoAuthorizationError < StandardError; end

    def self.included(base)
      base.class_eval do
        extend DSL
        extend ClassMethods
      end
    end

    module DSL
      def authorize(message_str_or_proc = 'User unauthorized', &blk)
        _define_authorize_step(message_str_or_proc, &blk)

        step(next_authorize_step_name)

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
      raise NoAuthorizationError, 'Make sure to define at least one *authorize* block for your use case (e.g. use `authorize { true }` to allow all users).'
    end

    module ClassMethods
      def _define_authorize_step(message_str_or_proc, &blk)
        define_method(next_authorize_step_name) do |previous_result, params, current_user|
          if blk.call(current_user, params, previous_result)
            return Success(previous_result)
          else
            message = _resolve_message(message_str_or_proc, current_user, params, previous_result)
            return Failure([:unauthorized, message])
          end
        end
      end
    end

    def _resolve_message(message, *args)
      message.is_a?(String) ? message : message.call(*args)
    end
  end
end
