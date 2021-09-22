# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/check_test_use_case"

RSpec.describe UseCases::StepAdapters::Check do
  subject { CheckTestUseCase.new.call(params, user) }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

  context "when the check method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

    it "fails" do
      expect(subject).to fail_with_code :user_not_admin
    end

    it "returns the error string" do
      expect(subject).to fail_with_payload "User not admin"
    end
  end

  context "when the try method succeeds" do
    before do
      allow(user).to receive(:admin?).and_return(true)
    end

    it "passes the previous return value to the next step" do
      expect(subject).to succeed_with "it succeeds!"
    end
  end
end
