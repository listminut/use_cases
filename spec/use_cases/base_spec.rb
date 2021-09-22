# frozen_string_literal: true

require "spec_helper"
require "support/test_subjects/base_test_use_case"

RSpec.describe UseCases::Base do
  subject { BaseTestUseCase.new }

  describe "#stack" do
    it "has all the defined steps" do
      expect(subject.stack.steps.count).to eq 4
    end

    it "has the defined steps in the right order" do
      expect(subject.stack.steps.map(&:name)).to eq %i[validate do_something do_something_else authorize_1]
    end
  end
end
