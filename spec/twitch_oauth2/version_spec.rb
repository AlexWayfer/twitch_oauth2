# frozen_string_literal: true

## `described_class` is `nil` when `describe` with `String`
# rubocop:disable RSpec/DescribeClass
describe 'TwitchOAuth2::VERSION' do
	# rubocop:enable RSpec/DescribeClass
	subject { Object.const_get(self.class.description) }

	it { is_expected.to match(/\d+\.\d+\.\d+/) }
end
