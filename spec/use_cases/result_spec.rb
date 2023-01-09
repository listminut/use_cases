require 'spec_helper'

RSpec.describe UseCases::Result do
  describe 'self' do
    context 'when used by a service using the do notation' do
      let(:caller) do
        require 'support/test_subjects/operation_calling_use_case'
        OperationCallingUseCase.new
      end

      it 'works' do
        expect(caller.call).to be_success
      end
    end
  end
end
