# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/locked_test_use_case"

RSpec.describe UseCases::ModuleOptins::Locked do
  subject { LockedTestUseCase.new }

  let(:locker) { double("A Locker") }
  let(:locked_executions) { {} }

  let(:user) { double("user", id: 1) }
  let(:params) { { id: 1 } }

  before do
    LockedTestUseCase.lock_with(timeout: 0.5) { |params, current_user| "my-key-#{params[:id]}-#{current_user.id}" }

    allow(subject).to receive(:locker).and_return locker

    allow(locker).to receive(:lock) do |key, options, &blk|
      waiting_for = 0

      while locked_executions[key] && waiting_for < options[:timeout].to_f
        sleep 0.1
        waiting_for += 0.1
      end
      next if waiting_for >= options[:timeout].to_f

      locked_executions[key] = true
      blk.call.tap { locked_executions.delete(key) }
    end
  end

  context "when it has a locked transaction ongoing" do
    it "does not allow executing 2 operations with the same key simultanerously" do
      threads = []
      expect(subject).to receive(:do_call).exactly(2).times
      threads << Thread.new { subject.call(params, user) }
      threads << Thread.new { subject.call(params, user) }
      threads.each(&:join)
      expect(locked_executions.size).to eq 0
    end

    context "when the key is locked" do
      let(:locked_executions) { { "my-key-1-1" => true } }

      it "does not execute an operation if the key is locked and times out if the locker does so" do
        expect(subject).not_to receive(:do_call)

        subject.call(params, user)
      end
    end
  end
end
