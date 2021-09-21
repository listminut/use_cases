# frozen_string_literal: true

require "active_support/hash_with_indifferent_access"

module UseCases
  class Params < ActiveSupport::HashWithIndifferentAccess
    def initialize(params)
      if defined?(Rails) && params.is_a?(ActionController::Parameters)
        super(params.permit!.to_h)
      else
        super(params)
      end
    end
  end
end
