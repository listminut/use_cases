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
      def authorize(step_name, options = {})
        options[:failure] = :unauthorized
        check step_name, **options
      end
    end
  end
end
