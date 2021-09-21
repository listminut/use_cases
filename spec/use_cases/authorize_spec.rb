require "spec_helper"

RSpec.describe UseCases::Authorize do
  class AuthorizeTestUseCase < UseCases::Base
    params {}

    step :load_something_necessary_for_authorize

    authorize proc { |user| "User #{user.email} cannot perform this action" } do |user, _params, previous_value|
      user.admin?(true) && previous_value
    end

    private

    def load_something_necessary_for_authorize
      Success("resource loaded before authorizing")
    end

    def run_something_after_authorizing(resource_loaded_before_authorizing)
      Success("previous result: #{resource_loaded_before_authorizing}")
    end
  end

  subject { AuthorizeTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { { required_string_param: "some string", value_checked_param: "some string" } }

  context "with an authorized user" do
    before do
      allow(user).to receive(:admin?).and_return(true)
    end

    it "succeeds and returns the contract" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure do |value|
          result = value
        end
      end

      expect(result).to eq "resource loaded before authorizing"
    end

    context "with an extra step after" do
      before do
        AuthorizeTestUseCase.step :run_something_after_authorizing
      end

      it "it funnels down the result received before authorization" do
        result = nil

        subject.call(params, user) do |match|
          match.success do |value|
            result = value
          end

          match.failure do |value|
            result = value
          end
        end

        expect(result).to eq "previous result: resource loaded before authorizing"
      end
    end
  end

  context "with an unauthorized user" do
    before do
      allow(user).to receive(:admin?).and_return(false)
      allow(user).to receive(:email).and_return("user@user.com")
    end

    it "fails with :unauthorized" do
      result = nil

      subject.call(params, user) do |match|
        match.failure :unauthorized do |(code, _errors)|
          result = code
        end

        match.success do |value|
          result = value
        end
      end

      expect(result).to eq(:unauthorized)
    end

    it "returns an error message" do
      result = nil

      subject.call(params, user) do |match|
        match.failure :unauthorized do |(_code, errors)|
          result = errors
        end

        match.success do |value|
          result = value
        end
      end

      expect(result).to eq "User user@user.com cannot perform this action"
    end
  end
end
