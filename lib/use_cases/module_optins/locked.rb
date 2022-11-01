# frozen_string_literal: true

require "use_cases/step_adapters/check"

module UseCases
  module ModuleOptins
    module Locked
      def self.included(base)
        super
        base.class_eval do
          extend DSL
          prepend CallPatch
        end
      end

      MissingLockConfiguration = Class.new(StandardError)
      MissingLockerError = Class.new(StandardError)

      module DSL
        attr_reader :_lock_with, :_lock_options

        def lock_with(options = {}, &blk)
          @_lock_with = blk || options.delete(:key)
          @_lock_options = options
        end
      end

      module CallPatch
        def call(*args)
          unless self.class._lock_with
            raise MissingLockConfiguration, "Locked use cases require setting `lock_with` to define the cache key and wait configuration.\n" \
                                            " Example: `lock_with { |params, curent_user| \"my-key-\#{params[:id]}-\#{curent_user.id}\" }`"
          end

          key = lock_with(*args)

          raise MissingLockerError, "Locked use cases require setting `locker` dependency to define the cache store.\n" unless respond_to?(:locker)

          locker.lock(key, lock_options) { super }
        end

        private

        def lock_options
          self.class._lock_options
        end

        def lock_with(*args)
          self.class._lock_with.is_a?(Proc) ? self.class._lock_with.call(*args) : self.class._lock_with
        end
      end
    end
  end
end
