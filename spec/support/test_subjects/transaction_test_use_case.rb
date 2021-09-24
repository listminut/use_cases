# frozen_string_literal: true

class TransactionTestUseCase < UseCases::Base[:transactional]
  SomeError = Class.new(StandardError)

  tee :run_something
  try :some_step, catch: SomeError, failure: :not_found

  private

  def run_something; end

  def some_step(params)
    raise SomeError if params[:raise_not_found]
  end
end
