# frozen_string_literal: true

require "rspec"

RSpec::Matchers.define(:fail_with_code) do |expected_code|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.first).to eq expected_code
  end
end

RSpec::Matchers.define(:fail_with_payload) do |expected_result|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure.last).to eq expected_result
  end
end

RSpec::Matchers.define(:fail_with) do |*expected_failure|
  match do |test_subject|
    expect(test_subject.failure?).to be true
    expect(test_subject.failure).to eq expected_failure
  end
end

RSpec::Matchers.define(:succeed_with) do |expected_result|
  match do |test_subject|
    expect(test_subject.success?).to be true
    expect(test_subject.success).to eq expected_result
  end
end
