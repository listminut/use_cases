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
    finalize_subscriptions!
  end

  def self.finalize_subscriptions!
    subscribe(*subscribers)
    return unless UseCases::Events::Subscriber.respond_to?(:descendants)

    usecase_subscriber_children = UseCases::Events::Subscriber.descendants
    subscribe(*usecase_subscriber_children)
    subscribers.concat(usecase_subscriber_children)
  end

  def self.subscribe(*subscribers)
    subscribers.each { |subscriber| publisher.subscribe(subscriber) }
  end
end
