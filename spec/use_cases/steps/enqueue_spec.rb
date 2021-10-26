# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/enqueue_test_use_case"

RSpec.describe UseCases::StepAdapters::Enqueue do
  subject { EnqueueTestUseCase.new }

  let(:user) { double("user") }
  let(:params) { {} }
  let(:job_arguments) do
    ["EnqueueTestUseCase", "some_task_to_be_performed_async",
     "something to be used by enqueue", params, user]
  end

  before do
    stub_const("ActiveJob", Module.new)
    stub_const("ActiveJob::Arguments", Module.new do
      def self.serialize_argument(arg)
        arg
      end
    end)
    stub_const("ActiveJob::Base", Class.new)
    stub_const("ActiveJob::SerializationError", Class.new(StandardError))

    load "use_cases/step_active_job_adapter.rb" unless defined? UseCases::StepActiveJobAdapter
    load "use_cases/step_adapters/enqueue.rb"

    EnqueueTestUseCase.register_adapter UseCases::StepAdapters::Enqueue

    EnqueueTestUseCase.enqueue :some_task_to_be_performed_async
  end

  it "enqueues a job" do
    expect(UseCases::StepActiveJobAdapter).to receive(:set).and_return(UseCases::StepActiveJobAdapter)
    expect(UseCases::StepActiveJobAdapter).to(
      receive(:perform_later)
      .with(*job_arguments)
    )

    subject.call(params, user)
  end

  it "performs the right action when the job received these arguments" do
    use_case = EnqueueTestUseCase.new
    allow(EnqueueTestUseCase).to receive(:new).and_return(use_case)

    expect(use_case).to(
      receive(:some_task_to_be_performed_async)
      .with("something to be used by enqueue", params, user)
    )

    UseCases::StepActiveJobAdapter.new.perform(*job_arguments)
  end
end
