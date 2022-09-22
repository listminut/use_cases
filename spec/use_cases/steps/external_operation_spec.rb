# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/external_operation"
require "support/test_subjects/external_operation_returning_monads"
require "support/test_subjects/use_case_with_external_operation"

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
      UseCaseWithExternalOperation.step :foo, with: ExternalOperationReturningMonads.new
    end

    after do
      UseCaseWithExternalOperation.remove_step :foo
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

  context "when theres another external operation step with a pass option" do
    let(:external_operation) { ExternalOperation.new }

    before do
      UseCaseWithExternalOperation.step :bar, with: external_operation, pass: [:params]
    end

    after do
      UseCaseWithExternalOperation.remove_step :bar
    end

    it "calls the external operation with the correct params" do
      result = nil

      expect(external_operation).to receive(:call).with(params).and_call_original

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure do |(code, _message)|
          result = code
        end
      end
    end
  end
end
