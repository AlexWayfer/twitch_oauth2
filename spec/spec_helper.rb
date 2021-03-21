# frozen_string_literal: true

require 'pry-byebug'

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV['TWITCH_CLIENT_ID'] ||= 'test_client_id'
ENV['TWITCH_CLIENT_SECRET'] ||= 'test_client_secret'
ENV['TWITCH_ACCESS_TOKEN'] ||= 'test_access_token'
ENV['TWITCH_REFRESH_TOKEN'] ||= 'test_refresh_token'
ENV['TWITCH_APPLICATION_ACCESS_TOKEN'] ||= 'test_application_access_token'

RSpec::Matchers.define_negated_matcher :not_output, :output

require 'vcr'

VCR.configure do |config|
	config.cassette_library_dir = "#{__dir__}/cassettes"
	config.default_cassette_options = {
		record_on_error: false,
		allow_unused_http_interactions: false
	}
	config.hook_into :faraday
	config.configure_rspec_metadata!

	config.filter_sensitive_data('<CLIENT_ID>') do
		ENV['TWITCH_CLIENT_ID']
	end

	config.filter_sensitive_data('<CLIENT_SECRET>') do
		ENV['TWITCH_CLIENT_SECRET']
	end

	config.filter_sensitive_data('<ACTUAL_ACCESS_TOKEN>') do
		ENV['TWITCH_ACCESS_TOKEN']
	end

	config.filter_sensitive_data('<ACTUAL_REFRESH_TOKEN>') do
		ENV['TWITCH_REFRESH_TOKEN']
	end

	config.filter_sensitive_data('<ACTUAL_APPLICATION_ACCESS_TOKEN>') do
		ENV['TWITCH_APPLICATION_ACCESS_TOKEN']
	end

	config.filter_sensitive_data('<CODE>') do |interaction|
		URI.decode_www_form(interaction.request.body).to_h['code']
	end

	config.filter_sensitive_data('<CODE>') do |interaction|
		JSON.parse(interaction.request.body).to_h['code']
	rescue JSON::ParserError
		## this is not JSON
	end

	config.filter_sensitive_data('<ACCESS_TOKEN>') do |interaction|
		if interaction.response.headers['content-type'].include? 'application/json'
			JSON.parse(interaction.response.body)['access_token']
		end
	end

	config.filter_sensitive_data('<REFRESH_TOKEN>') do |interaction|
		if interaction.response.headers['content-type'].include? 'application/json'
			JSON.parse(interaction.response.body)['refresh_token']
		end
	end
end

require_relative '../lib/twitch_oauth2'

# TwitchOAuth2::Client::CONNECTION
# 	.response :logger, nil, { headers: true, bodies: true }
