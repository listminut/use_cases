# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/events_test_use_case"

RSpec.describe UseCases::ModuleOptins::Publishing do
  subject { EventsTestUseCase.new }

  let(:params) { { params: "params" } }
  let(:user) { double("user") }
  let(:payload) { double("payload") }
  let(:result) { double("result", success?: true, value!: payload) }

  context "when it raises an error caught by the transaction" do
    before do
      allow(result).to receive(:is_a?).with(Dry::Monads::Result).and_return(true)
      allow(user).to receive(:admin?).and_return(true)
    end

    it "publishes an event for each step" do
      expect(UseCases.publisher).to receive(:publish).with('events.step.success', params)
      expect(UseCases.publisher).to receive(:publish).with('events.try.failure', [nil, ""])
      subject.call(params, user)
    end

    context "when active jobs is defined" do
      before do
        stub_const("ActiveJob", Module.new)
        stub_const("ActiveJob::Base", Class.new)
        
        load "use_cases/events/publish_job.rb"
      end

      it "published an async event for each step" do
        expect(UseCases::Events::PublishJob).to receive(:perform_later).with('events.step.success', params.to_json)
        expect(UseCases::Events::PublishJob).to receive(:perform_later).with('events.try.failure', [nil, ""].to_json)
        

        subject.call(params, user)
      end
    end
  end
end
