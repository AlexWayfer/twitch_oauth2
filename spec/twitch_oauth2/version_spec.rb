# frozen_string_literal: true

describe(const_name = 'TwitchOAuth2::VERSION') do
	subject { Object.const_get(const_name) }

	it { is_expected.to match(/\d+\.\d+\.\d+/) }
end
