# frozen_string_literal: true

require "byebug"
require "spec_helper"
require "support/test_subjects/events_test_use_case"
require "support/test_subjects/test_subscriber"

RSpec.describe UseCases::ModuleOptins::Publishing do
  subject { EventsTestUseCase.new }

  let(:params) { { foo: "bar" } }
  let(:user) { double("user") }
  let(:payload) { double("payload") }
  let(:result) { double("result", success?: true, value!: payload) }

  before do
    stub_const("ActiveJob", Module.new)
    stub_const("ActiveJob::Base", Class.new)

    load "use_cases/events/publish_job.rb" unless defined? UseCases::Events::PublishJob

    allow(UseCases::Events::PublishJob).to receive(:perform_later)
  end

  context "when it raises an error caught by the transaction" do
    before do
      allow(result).to receive(:is_a?).with(Dry::Monads::Result).and_return(true)
      allow(user).to receive(:admin?).and_return(true)
    end

    context "when active jobs is defined" do
      it "published an async event for each step" do
        expect(UseCases::Events::PublishJob).to receive(:perform_later).with("events.step.success", {
          return_value: "result",
          params: params,
          current_user: user
        })
        expect(UseCases::Events::PublishJob).to receive(:perform_later).with("events.try.failure", {
          return_value: [:failed, "Failed"],
          params: params,
          current_user: user
        })

        subject.call(params, user)
      end
    end
  end

  context "when there are subscribers to the event" do
    it "subscribes to the event" do
      test_subscriber = TestSubscriber.new
      expect(UseCases).to receive(:subscribers).and_return([test_subscriber]).at_least(:once)
      expect(test_subscriber).to receive(:on_events_step_success)
      expect(test_subscriber).to receive(:on_events_try_failure)
      subject.call(params, user)
    end
  end
end
 