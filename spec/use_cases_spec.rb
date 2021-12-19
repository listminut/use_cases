# frozen_string_literal: true

SomeContainer = Class.new
SomePublisher = Class.new

RSpec.describe UseCases do
  it "has a version number" do
    expect(UseCases::VERSION).not_to be nil
  end

  describe "::config" do
    describe "::container" do
      it "returns the registered container" do
        UseCases.configure do |config|
          config.container = SomeContainer
        end

        expect(UseCases.container).to eq SomeContainer
      end
    end
  end

  describe "::config" do
    describe "::publisher" do
      it "returns the registered publisher" do
        UseCases.configure do |config|
          config.publisher = SomePublisher
        end

        expect(UseCases.publisher).to eq SomePublisher
      end
    end
  end
end
