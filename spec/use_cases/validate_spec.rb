require "spec_helper"

RSpec.describe UseCases::Validate do
  class ValidateTestUseCase < UseCases::Base
    params do
      required(:required_string_param).filled(:string)
      required(:value_checked_param).value(eql?: "some string")
    end
  end

  subject { ValidateTestUseCase.new }

  let(:user) { double("user") }

  before do
    allow(user).to receive(:admin?).and_return(true)
  end

  context "with valid params" do
    let(:params) { { required_string_param: "some string", value_checked_param: "some string" } }

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

      expect(result).to be_success
    end
  end

  context "with invalid params" do
    let(:params) { { required_string_param: 1, value_checked_param: "some other string" } }

    it "fails with :validation_failure" do
      result = nil

      subject.call(params, user) do |match|
        match.failure :validation_error do |(_code, errors)|
          result = errors
        end

        match.success do |value|
          result = value
        end
      end

      expect(result).to eq({ value_checked_param: ["must be equal to some string"],
                             required_string_param: ["must be a string"] })
    end
  end
end
