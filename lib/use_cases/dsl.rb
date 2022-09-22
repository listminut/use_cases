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

    def remove_step(name)
      __steps__.delete_if { |step| step.name == name }
    end

    def __steps__
      @__steps__ ||= []
    end
  end
end
