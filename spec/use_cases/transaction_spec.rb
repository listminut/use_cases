# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/transaction_test_use_case"

RSpec.describe UseCases::Transaction do
  subject { TransactionTestUseCase.new }
  let(:transaction_handler) { double("A Transaction Handler") }

  let(:user) { double("user") }

  before do
    allow(subject).to receive(:transaction_handler).and_return transaction_handler
  end

  context "when it raises an error caught by the transaction" do
    let(:params) { { raise_not_found: true } }

    before do
      allow(transaction_handler).to receive(:transaction) { |&blk| raise StandardError if blk.call.failure? }
      allow(user).to receive(:admin?).and_return(true)
    end

    it "raises an error that can be used to rollback" do
      expect { subject.call(params, user) }.to raise_error StandardError
    end
  end
end
