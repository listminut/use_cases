# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/tee_test_use_case"

RSpec.describe UseCases::StepAdapters::Tee do
  subject { TeeTestUseCase.new.call(params, user) }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
  end

  context "when the tee method returns false" do
    before do
      allow(user).to receive(:admin?).and_return(false)
    end

    it "succeeds" do
      expect(subject).to be_successful_with "it succeeds!"
    end
  end
end
