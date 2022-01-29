# frozen_string_literal: true

require "dry/configurable"

require_relative "use_case"
require_relative "use_cases/version"

module UseCases
  class StepArgumentError < ArgumentError; end

  class MissingStepError < NoMethodError; end

  class PreviousStepInvalidReturn < StandardError; end

  extend Dry::Configurable

  setting :container, reader: true
  setting :publisher, ::UseCases::Events::Publisher, reader: true
  setting :subscribers, [], reader: true
end
