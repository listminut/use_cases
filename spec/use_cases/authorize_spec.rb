# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/authorize_test_use_case"

RSpec.describe UseCases::Authorize do
  subject { AuthorizeTestUseCase.new.call(params, user) }

  let(:user) { double("user") }
  let(:params) { { required_string_param: "some string", value_checked_param: "some string" } }

  context "with an authorized user" do
    before do
      allow(user).to receive(:admin?).and_return(true)
    end

    it "succeeds and returns the contract" do
      expect(subject).to succeed_with "resource loaded before authorizing"
    end

    context "with an extra step after" do
      before do
        AuthorizeTestUseCase.step :run_something_after_authorizing
      end

      it "it funnels down the result received before authorization" do
        expect(subject).to succeed_with "previous result: resource loaded before authorizing"
      end
    end
  end

  context "with an unauthorized user" do
    before do
      allow(user).to receive(:admin?).and_return(false)
      allow(user).to receive(:email).and_return("user@user.com")
    end

    it "fails with :unauthorized" do
      expect(subject).to fail_with_code :unauthorized
    end

    it "returns an error message" do
      expect(subject).to fail_with_result "User needs to be admin."
    end
  end
end
