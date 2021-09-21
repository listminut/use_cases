require "dry/monads/all"
require "byebug"

module UseCases
  module Steps
    class Abstract
      include Dry::Monads

      include Dry::Events::Publisher[name || object_id]

      def self.inherited(subclass)
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
        @external = options[:with]
        @failure = options[:failure]
      end

      def call(*args)
        publish_events(args) { do_call(*args) }
      end

      def do_call(*args)
        external ? object.call(*args) : object.send(name, *args)
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

    class Step < Abstract; end

    class Map < Abstract; end

    class Try < Abstract
      def do_call(*args)
        Success(super(*args))
      rescue StandardError => e
        Failure([failure, e.message])
      end
    end

    class LoadResource < Try
      def intitialize(*args)
        super(*args)
        @failure = :not_found
      end
    end

    class Tee < Abstract
      def call(*args)
        Success(super(*args))
      end
    end
  end
end
