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

	spec.required_ruby_version = '>= 2.6', '< 4'

	spec.add_dependency 'faraday', '~> 2.3'
	spec.add_dependency 'faraday_middleware', '~> 1.0'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.11.0'
	spec.add_development_dependency 'toys', '~> 0.13.0'

	spec.add_development_dependency 'codecov', '~> 0.6.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.21.2'
	spec.add_development_dependency 'vcr', '~> 6.0'

	spec.add_development_dependency 'rubocop', '~> 1.29.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
