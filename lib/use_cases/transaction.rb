# frozen_string_literal: true

module UseCases
  module Transaction
    def self.included(base)
      base.prepend CallPatch
    end

    module CallPatch
      def call(*args)
        return super unless respond_to?(:transaction_handler)

        transaction_handler.transaction { super }
      end
    end
  end
end
