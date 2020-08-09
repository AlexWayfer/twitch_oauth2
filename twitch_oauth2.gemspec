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

	spec.required_ruby_version = '>= 2.5'

	source_code_uri = 'https://github.com/AlexWayfer/twitch_oauth2'

	spec.homepage = source_code_uri

	spec.metadata['source_code_uri'] = source_code_uri

	spec.metadata['homepage_uri'] = spec.homepage

	# TODO: Put your gem's CHANGELOG.md URL here.
	# spec.metadata["changelog_uri"] = ""

	# Specify which files should be added to the gem when it is released.
	# The `git ls-files -z` loads the files in the RubyGem that have been added
	# into git.
	spec.files = Dir.chdir(__dir__) do
		`git ls-files -z`.split("\x0").reject do |file|
			file.match(%r{^(test|spec|features)/})
		end
	end
	spec.bindir        = 'exe'
	spec.executables   = spec.files.grep(%r{^exe/}) { |file| File.basename(file) }
	spec.require_paths = ['lib']

	spec.add_dependency 'faraday', '~> 1.0'
	spec.add_dependency 'faraday_middleware', '~> 1.0'

	spec.add_development_dependency 'codecov', '~> 0.1.0'
	spec.add_development_dependency 'mdl', '~> 0.10.0'
	spec.add_development_dependency 'pry-byebug', '~> 3.9'
	spec.add_development_dependency 'rake', '~> 13.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'rubocop', '~> 0.83.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 1.0'
	spec.add_development_dependency 'simplecov', '~> 0.18.0'
	spec.add_development_dependency 'vcr', '~> 5.1'
end
