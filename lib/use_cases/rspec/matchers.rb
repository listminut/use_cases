# frozen_string_literal: true

require "rspec"

RSpec::Matchers.define(:be_failure_with_code) do |expected_code|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.first).to eql expected_code
  end

  failure_message do |test_subject|
    if test_subject.failure?
      "the use case was expected to fail with code #{expected_code} but it returned #{test_subject.failure.first}"
    else
      "the use case was expected to fail with code #{expected_code} but it did not fail"
    end
  end
end

RSpec::Matchers.define(:be_failure_with_payload) do |expected_result|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.last).to eql expected_result
  end

  failure_message do |test_subject|
    if test_subject.failure?
      "the use case was expected to fail with #{expected_result.inspect} but it returned #{test_subject.failure.last.inspect}"
    else
      "the use case was expected to fail but it succeeded with #{test_subject.success.inspect}"
    end
  end
end

RSpec::Matchers.define(:be_failure_with) do |*expected_failure|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure).to eql expected_failure
  end

  expected_result, expected_code = expected_failure

  failure_message do |test_subject|
    if test_subject.failure?
      "the use case was expected to fail with #{expected_code} and #{expected_result.inspect} but it returned #{test_subject.failure.inspect}"
    else
      "the use case was expected to fail but it succeeded with #{test_subject.success.inspect}"
    end
  end
end

RSpec::Matchers.define(:be_successful_with) do |expected_result|
  match do |test_subject|
    expect(test_subject.success?).to be true
    expect(test_subject.success).to eql expected_result
  end

  failure_message do |test_subject|
    if test_subject.success?
      "the use case was expected to succeed with #{expected_result.inspect} but it returned #{test_subject.success.inspect}"
    else
      "the use case was expected to succeed but it failed with #{test_subject.failure.inspect}"
    end
  end
end
