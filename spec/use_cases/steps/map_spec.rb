# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/map_test_use_case"

RSpec.describe UseCases::StepAdapters::Map do
  subject { MapTestUseCase.new.call(params, user) }

  let(:user) { double("user") }
  let(:params) { {} }

  context "when the map method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

    it "succeeds" do
      expect(subject).to be_successful_with true
    end
  end
end
