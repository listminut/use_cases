# frozen_string_literal: true

require "dry/configurable"
require "dry/types"

require_relative "use_case"
require_relative "use_cases/version"

module UseCases
  class StepArgumentError < ArgumentError; end

  class MissingStepError < NoMethodError; end

  class PreviousStepInvalidReturn < StandardError; end

  extend Dry::Configurable

  setting :container, reader: true
  setting :publisher, default: ::UseCases::Events::Publisher.new, reader: true
  setting :subscribers, default: [], reader: true
  setting :dry_validation, default: ->(config) {}

  def self.dry_validation
    config_proc = config.dry_validation

    Proc.new do 
      config_proc.call(config)
    end
  end
end
