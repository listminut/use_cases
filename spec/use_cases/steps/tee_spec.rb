# frozen_string_literal: true

require "spec_helper"
require "support/tee_test_use_case"

RSpec.describe UseCases::StepAdapters::Tee do
  subject { TeeTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

  context "when the tee method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

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

      expect(result).to eq "it succeeds!"
    end
  end
end
