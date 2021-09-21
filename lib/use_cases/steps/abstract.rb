# frozen_string_literal: true

require "dry/monads/all"

module UseCases
  module Steps
    class Abstract
      include Dry::Monads

      include Dry::Events::Publisher[name || object_id]

      def self.inherited(subclass)
        super
        subclass.register_event(:step)
        subclass.register_event(:step_succeeded)
        subclass.register_event(:step_failed)
      end

      include Dry::Monads[:result]

      attr_reader :name, :object, :external, :failure, :options

      def initialize(name, *args, **options)
        @name = name
        @object = args.first
        @options = options
      end

      def previous_step_result
        object.stack.prev_step_result
      end

      def call(*args)
        publish_events(args) { do_call(*args) }
      end

      def do_call(*args)
        options[:with] ? object.call(*args) : object.send(name, *args)
      end

      def publish_events(args)
        publish(:step, step_name: name, args: args)

        result = StepResult.new(self, yield)

        if result.success?
          publish(:step_succeeded, step_name: name, args: args, value: result.value)
        else
          publish(:step_failed, step_name: name, args: args, value: result.value)
        end

        result
      end

      def bind(object)
        object = external ? object.send(external) : object

        self.class.new(name, object, options)
      end

      def args_count
        object.method(name).parameters.count
      end

      def missing?
        !object.respond_to?(name, true)
      end
    end

    class Map < Abstract
      def call(*args)
        Success(super(*args))
      end
    end

    class Try < Abstract
      def do_call(*args)
        Success(super(*args))
      rescue options[:catch] || StandardError => e
        Failure([options[:failure], e.message])
      end
    end

    class Check < Abstract
      def do_call(*args)
        result = super(*args)
        result ? Success(result) : Failure([options[:failure], result])
      end
    end

    class Tee < Abstract
      def do_call(*args)
        super(*args)
        Success(previous_step_result.value)
      end
    end
  end
end
