# frozen_string_literal: true

describe(constant = TwitchOAuth2::VERSION) do
	subject { constant }

	it { is_expected.to match(/\d+\.\d+\.\d+/) }
end
