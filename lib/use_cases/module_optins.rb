# frozen_string_literal: true

require "use_cases/module_optins/prepared"
require "use_cases/module_optins/transactional"
require "use_cases/module_optins/validated"
require "use_cases/module_optins/publishing"
require "use_cases/module_optins/authorized"

module UseCases
  module ModuleOptins
    attr_accessor :options

    OPTINS = {
      authorized: Authorized,
      transactional: Transactional,
      validated: Validated,
      prepared: Prepared,
      publishing: Publishing
    }.freeze

    def [](*options)
      modules = [self]

      OPTINS.each do |key, module_constant|
        modules << module_constant if options.include?(key)
      end

      supermodule = Module.new

      supermodule.define_singleton_method(:included) do |base|
        base.include(*modules)
      end

      supermodule
    end

    def descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end
end
