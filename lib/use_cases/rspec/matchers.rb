# frozen_string_literal: true

require "rspec"

RSpec::Matchers.define(:be_failure_with_code) do |expected_code|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.first).to eq expected_code
  end

  failure_message do |test_subject|
    "the use case was expected to fail with code #{expected_code} but it returned #{test_subject.failure.first}"
  end
end

RSpec::Matchers.define(:be_failure_with_payload) do |expected_result|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.last).to eq expected_result
  end

  failure_message do |test_subject|
    "the use case was expected to fail with #{expected_result.inspect} but it returned #{test_subject.failure.last.inspect}"
  end  
end

RSpec::Matchers.define(:be_failure_with) do |*expected_failure|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure).to eq expected_failure
  end

  failure_message do |test_subject|
    "the use case was expected to fail with #{expected_result.inspect} but it returned #{test_subject.failure.inspect}"
  end    
end

RSpec::Matchers.define(:be_successful_with) do |expected_result|
  match do |test_subject|
    expect(test_subject.success?).to be true
    expect(test_subject.success).to eq expected_result
  end

  failure_message do |test_subject|
    "the use case was expected to succeed with #{expected_result.inspect} but it returned #{test_subject.success.inspect}"
  end    
end
