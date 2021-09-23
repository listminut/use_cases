# frozen_string_literal: true

module UseCases
  module Transaction
    class TransactionHandlerUndefined < StandardError; end

    class TransactionHandlerInvalid < StandardError; end

    def self.included(base)
      base.prepend DoCallPatch
    end

    module DoCallPatch
      def do_call(*args)
        unless respond_to?(:transaction_handler)
          raise TransactionHandlerUndefined, "when using *transactional*, make sure to include a transaction handler in your dependencies."
        end

        raise TransactionHandlerInvalid, "Make sure your transaction_handler implements #transaction." unless transaction_handler.respond_to?(:transaction)

        transaction_handler.transaction { super }
      end
    end
  end
end
