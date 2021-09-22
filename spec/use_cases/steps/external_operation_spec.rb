# frozen_string_literal: true

require "spec_helper"
require "support/external_operation"
require "support/use_case_with_external_operation"

RSpec.describe UseCases::StepAdapters::Step do
  subject { UseCaseWithExternalOperation.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

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
end
