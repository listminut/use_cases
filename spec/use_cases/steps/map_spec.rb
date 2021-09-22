# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/map_test_use_case"

RSpec.describe UseCases::StepAdapters::Map do
  subject { MapTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

  context "when the map method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

    it "succeeds" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :user_not_admin do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq true
    end
  end
end
