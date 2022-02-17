# frozen_string_literal: true

SomeContainer = Class.new
SomePublisher = Class.new

RSpec.describe UseCases do
  it "has a version number" do
    expect(UseCases::VERSION).not_to be nil
  end

  describe ".config" do
    describe ".container" do
      it "returns the registered container" do
        UseCases.configure do |config|
          config.container = SomeContainer
        end

        expect(UseCases.container).to eq SomeContainer
      end
    end

    describe ".publisher" do
      it "returns the registered publisher" do
        UseCases.configure do |config|
          config.publisher = SomePublisher
        end

        expect(UseCases.publisher).to eq SomePublisher
      end
    end

    describe '.dry_validation' do
      it 'allows for setting default values in validated use cases' do
        UseCases.configure do |config|
          config.dry_validation = lambda do |contract_config|
            contract_config.messages.backend = :i18n
          end
        end

        MyCase = Class.new do
          include UseCase[:validated]

          params do
            required(:foo).filled(:string)
          end
        end

        expect(MyCase.new.send(:contract).config.messages.backend).to eq :i18n
      end
    end
  end
end
