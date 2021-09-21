# frozen_string_literal: true

require "spec_helper"

RSpec.describe UseCases::Steps::Try do
  class TryTestUseCase < UseCases::Base
    params {}

    try :do_something, failure: :failed_with_an_error

    step :do_something_after

    def do_something(params, user); end

    def do_something_after(prev_result)
      Success("previous message: #{prev_result}")
    end
  end

  subject { TryTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }

  before do
    allow(user).to receive(:admin?).and_return(true)
  end

  context "when the try method raises an error" do
    before do
      allow(subject).to receive(:do_something).and_raise(StandardError, "some error")
    end

    it "fails" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :failed_with_an_error do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq :failed_with_an_error
    end

    it "returns the error string" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :failed_with_an_error do |(_code, message)|
          result = message
        end
      end

      expect(result).to eq "some error"
    end
  end

  context "when the try method succeeds" do
    before do
      allow(subject).to receive(:do_something).and_return("it succeeds!")
    end

    it "passes it's return value to the next step" do
      result = nil

      subject.call(params, user) do |match|
        match.success do |value|
          result = value
        end

        match.failure :failed_with_an_error do |(code, _message)|
          result = code
        end
      end

      expect(result).to eq "previous message: it succeeds!"
    end
  end
end
