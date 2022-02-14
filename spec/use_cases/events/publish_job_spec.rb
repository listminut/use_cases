# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/events_test_use_case"

RSpec.describe "testing the job" do
  subject { ::UseCases::Events::PublishJob.new }

  let(:event_key) { "event_key" }
  let(:payload) { double("payload") }

  context "when it raises an error caught by the transaction" do
    before do
      stub_const("ActiveJob", Module.new)
      stub_const("ActiveJob::Base", Class.new)

      allow(ActiveJob::Base).to receive(:perform_later)

      load "use_cases/events/publish_job.rb"
    end

    it "publishes an event for each step" do
      expect(UseCases.publisher).to receive(:publish).with("event_key.async", payload)

      subject.perform(event_key, payload)
    end
  end
end
