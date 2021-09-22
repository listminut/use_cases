# frozen_string_literal: true

require "spec_helper"
require "support/check_test_use_case"

RSpec.describe UseCases::StepAdapters::Check do
  subject { CheckTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

  context "when the check method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

    it "fails" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :user_not_admin do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq :user_not_admin
    end

    it "returns the error string" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :user_not_admin do |(_code, message)|
          result = message
        end
      end

      expect(result).to eq "User not admin"
    end
  end

  context "when the try method succeeds" do
    before do
      allow(user).to receive(:admin?).and_return(true)
    end

    it "passes the previous return value to the next step" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :user_not_admin do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq "it succeeds!"
    end
  end
end
