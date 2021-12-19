# frozen_string_literal: true

require "active_support/inflector"

return unless defined? ActiveJob

module UseCases
  class StepActiveJobAdapter < ActiveJob::Base
    def perform(use_case_name, step_name, *args)
      args = deserialize_step_arguments(args)

      use_case = ActiveSupport::Inflector.constantize(use_case_name)
      use_case.new.send(step_name, *args)
    end

    def deserialize_step_arguments(args)
      args.map do |arg|
        if arg.is_a?(Hash) && arg.delete("_serialized_by_use_case")
          arg.delete("_class").constantize.new(arg)
        else
          arg
        end
      end
    end

    def self.serialize_step_arguments(args)
      args.select.map.with_index do |arg, index|
        ActiveJob::Arguments.send(:serialize_argument, arg)
      rescue ActiveJob::SerializationError => _e
        arg.serialize.merge("_serialized_by_use_case" => true, "_class" => arg.class.name)
      rescue NoMethodError => _e
        puts "[WARNING] #{arg} of class (#{arg.clas}) (index = #{index})" \
             "is not serializable and does not repond to #serialize and will be ignored."
      else
        arg
      end
    end
  end
end
