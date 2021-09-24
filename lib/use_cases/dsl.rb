# frozen_string_literal: true

require "active_support/inflector/methods"

module UseCases
  module DSL
    include ActiveSupport::Inflector

    def register_adapter(step_class)
      step_name = underscore(demodulize(step_class.name))

      define_singleton_method(step_name) do |name, options = {}|
        __steps__ << step_class.new(name, nil, options)
      end
    end

    def __steps__
      @__steps__ ||= []
    end

    def subscribe(listeners)
      @listeners = listeners

      if listeners.is_a?(Hash)
        listeners.each do |step_name, listener|
          __steps__.detect { |step| step.name == step_name }.subscribe(listener)
        end
      else
        __steps__.each do |step|
          step.subscribe(listeners)
        end
      end
    end
  end
end
