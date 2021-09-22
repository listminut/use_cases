require "rspec"
# rubocop:disable Lint/UnusedBlockArgument

RSpec::Matchers.define(:match_failure_code) do |expected_code|
  match do |test_subject|
    failure_code = nil

    test_subject do |m|
      m.failure do |(code, _)|
        failure_code = code
      end
    end

    expect(failure_code).to eq expected_code
  end
end

RSpec::Matchers.define(:match_failure_result) do |expected_result|
  match do |test_subject|
    failure_result = nil

    test_subject do |m|
      m.failure do |(_, result)|
        failure_result = result
      end
    end

    expect(failure_result).to eq expected_result
  end
end

RSpec::Matchers.define(:match_failure) do |expected_code, expected_result|
  match do |test_subject|
    failure = nil

    test_subject do |m|
      m.failure do |failure_match|
        failure = failure_match
      end
    end

    expect(failure).to eq [expected_code, expected_result]
  end
end

RSpec::Matchers.define(:match_success) do |expected_result|
  match do |test_subject|
    success = nil

    test_subject do |m|
      m.success do |success_match|
        success = success_match
      end
    end

    expect(failure).to eq [expected_code, expected_result]
  end
end

# rubocop:enable Lint/UnusedBlockArgument
