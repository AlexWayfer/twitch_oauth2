# frozen_string_literal: true

describe 'TwitchOAuth2::VERSION' do
	subject { Object.const_get(self.class.description) }

	it { is_expected.to match(/^\d+\.\d+\.\d+$/) }
end
