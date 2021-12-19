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
  setting :publisher, ::UseCases::Events::Publisher.new, reader: true
  setting :subscribers, [], reader: true

  def self.configure(&blk)
    super
    subscribe
  end

  def self.subscribe
    subscribers.each { |subscriber| publisher.subscribe(subscriber) }
  end
end
