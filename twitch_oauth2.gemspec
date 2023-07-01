# frozen_string_literal: true

require_relative 'lib/twitch_oauth2/version'

Gem::Specification.new do |spec|
	spec.name          = 'twitch_oauth2'
	spec.version       = TwitchOAuth2::VERSION
	spec.authors       = ['Alexander Popov']
	spec.email         = ['alex.wayfer@gmail.com']

	spec.summary       = 'Twitch authentication with OAuth 2.'
	spec.description   = <<~DESC
		Twitch authentication with OAuth 2.
		Result tokens can be used for API libraries, chat libraries
		or something else.
	DESC
	spec.license = 'MIT'

	source_code_uri = 'https://github.com/AlexWayfer/twitch_oauth2'

	spec.homepage = source_code_uri

	spec.metadata['source_code_uri'] = source_code_uri

	spec.metadata['homepage_uri'] = spec.homepage

	spec.metadata['changelog_uri'] =
		'https://github.com/AlexWayfer/twitch_oauth2/blob/main/CHANGELOG.md'

	spec.metadata['rubygems_mfa_required'] = 'true'

	spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

	spec.required_ruby_version = '>= 2.7', '< 4'

	spec.add_dependency 'faraday', '2.7.9'
	spec.add_dependency 'faraday-parse_dates', '~> 0.1.0'
end
