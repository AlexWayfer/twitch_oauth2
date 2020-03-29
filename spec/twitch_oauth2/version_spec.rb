# frozen_string_literal: true

## `described_class` is `nil` when `describe` with `String`
# rubocop:disable RSpec/DescribeClass
describe(const_name = 'TwitchOAuth2::VERSION') do
	# rubocop:enable RSpec/DescribeClass
	subject { Object.const_get(const_name) }

	it { is_expected.to match(/\d+\.\d+\.\d+/) }
end
