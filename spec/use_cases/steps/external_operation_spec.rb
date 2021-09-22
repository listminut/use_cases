# frozen_string_literal: true

require "spec_helper"
require "support/external_operation"
require "support/external_operation_returning_monads"
require "support/use_case_with_external_operation"

RSpec.describe UseCases::StepAdapters::Step do
  subject { UseCaseWithExternalOperation.new }

  let(:user) { double("user") }
  let(:params) { {} }

  context "it returns the message returned by the external operation" do
    it "succeeds" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq "the external operation succeeds!"
    end
  end

  context "when theres another external operation that fails" do
    before do
      UseCaseWithExternalOperation.step :another_external_operation, with: ExternalOperationReturningMonads.new
    end

    it "fails" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq :no_bueno
    end
  end
end
