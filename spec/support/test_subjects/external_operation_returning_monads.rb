# frozen_string_literal: true

require "dry/monads/all"

class ExternalOperationReturningMonads
  include Dry::Monads[:result]

  def call
    Failure([:no_bueno, "it fails"])
  end
end
