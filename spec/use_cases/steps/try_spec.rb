# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/try_test_use_case"

RSpec.describe UseCases::StepAdapters::Try do
  subject { TryTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
    allow(user).to receive(:admin?).and_return(true)
  end

  context "when the try method raises the catched error" do
    before do
      allow(subject).to receive(:do_something).and_raise(TryTestUseCase::SomeError, "some error")
    end

    it "fails" do
      expect(subject.call(params, user)).to fail_with_code :failed_with_an_error
    end

    it "returns the error string" do
      expect(subject.call(params, user)).to fail_with_payload "some error"
    end
  end

  context "when the try method raises another error" do
    before do
      allow(subject).to receive(:do_something).and_raise(StandardError, "some error")
    end

    it "fails" do
      expect { subject.call(params, user) {} }.to raise_error StandardError
    end
  end

  context "when the try method succeeds" do
    before do
      allow(subject).to receive(:do_something).and_return("it succeeds!")
    end

    it "passes it's return value to the next step" do
      expect(subject.call(params, user)).to succeed_with "previous message: it succeeds!"
    end
  end
end
