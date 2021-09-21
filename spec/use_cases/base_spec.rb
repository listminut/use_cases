require "spec_helper"

RSpec.describe UseCases::Base do
  class BaseUseCase < UseCases::Base
    params do
      required(:required_string_param).filled(:string)
      required(:type_checked_param).value(:string)
    end

    step :do_something

    try :do_something_else

    authorize do |user, _params, _do_something_else_result|
      user.admin?
    end

    private

    def do_something(validation_result, params, user); end

    def do_something_else(do_something_result, params, user); end
  end

  subject { BaseUseCase.new }

  describe "::ancestors" do
  end

  describe "#stack" do
    it "has all the defined steps" do
      expect(subject.stack.steps.count).to eq 4
    end

    it "has the defined steps in the right order" do
      expect(subject.stack.steps.map(&:name)).to eq %i[validate do_something do_something_else authorize_1]
    end
  end
end
