# frozen_string_literal: true

require 'faraday'
require 'json'
require 'securerandom'

module TwitchOAuth2
	## Client for making requests
	class Client
		CONNECTION = Faraday.new(
			url: 'https://id.twitch.tv/oauth2/'
		) do |connection|
			connection.request :url_encoded
		end.freeze

		def initialize(
			client_id:, client_secret:, redirect_uri: 'http://localhost', scopes: nil
		)
			@client_id = client_id
			@client_secret = client_secret
			@redirect_uri = redirect_uri
			@scopes = scopes

			@state = SecureRandom.alphanumeric(32)
		end

		def flow(scopes: @scopes, access_token: nil, refresh_token: nil)
			if access_token
				result = validate access_token: access_token

				return refresh(refresh_token: refresh_token) if result[:status] == 401

				return result if result[:expires_in].positive?
			end

			flow_with_authorize scopes: scopes
		end

		private

		def flow_with_authorize(scopes:)
			link = authorize scopes: scopes

			puts <<~TEXT
				1. Open URL in your browser:
					#{link}
				2. Login to Twitch.
				3. Copy the `code` parameter from redirected URL.
				4. Insert below:
			TEXT

			code = STDIN.gets.chomp

			token code: code
		end

		def authorize(scopes: @scopes)
			scope = transform_scopes_to_string scopes

			response = CONNECTION.get(
				'authorize',
				client_id: @client_id,
				redirect_uri: @redirect_uri,
				scope: scope,
				response_type: :code
			)

			response.headers[:location]
		end

		def token(code:)
			response = CONNECTION.post(
				'token',
				client_id: @client_id,
				client_secret: @client_secret,
				code: code,
				grant_type: :authorization_code,
				redirect_uri: @redirect_uri
			)

			parse_json_response response.body
		end

		def validate(access_token:)
			response = CONNECTION.get(
				'validate', {}, { 'Authorization' => "OAuth #{access_token}" }
			)

			parse_json_response response.body
		end

		def refresh(refresh_token:)
			response = CONNECTION.post(
				'token',
				client_id: @client_id,
				client_secret: @client_secret,
				grant_type: :refresh_token,
				refresh_token: refresh_token
			)

			parse_json_response response.body
		end

		def transform_scopes_to_string(scopes)
			Array(scopes).join(' ')
		end

		def parse_json_response(string)
			JSON.parse(string).transform_keys(&:to_sym)
		end
	end
end
