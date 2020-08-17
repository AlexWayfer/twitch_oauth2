# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'securerandom'

module TwitchOAuth2
	## Client for making requests
	class Client
		CONNECTION = Faraday.new(
			url: 'https://id.twitch.tv/oauth2/'
		) do |connection|
			connection.request :json

			connection.response :dates

			connection.response :json,
				content_type: /\bjson$/,
				parser_options: { symbolize_names: true }
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

		def check_tokens(access_token: nil, refresh_token: nil)
			if access_token
				validate_result = validate access_token: access_token

				return refreshed_tokens(refresh_token: refresh_token) if validate_result[:status] == 401

				if validate_result[:expires_in].positive?
					return { access_token: access_token, refresh_token: refresh_token }
				end
			end

			flow
		end

		def refreshed_tokens(refresh_token:)
			refresh(refresh_token: refresh_token).slice(:access_token, :refresh_token)
		end

		private

		def flow
			link = authorize

			puts <<~TEXT
				1. Open URL in your browser:
					#{link}
				2. Login to Twitch.
				3. Copy the `code` parameter from redirected URL.
				4. Insert below:
			TEXT

			code = $stdin.gets.chomp

			token(code: code).slice(:access_token, :refresh_token)
		end

		def authorize
			response = CONNECTION.get(
				'authorize',
				client_id: @client_id,
				redirect_uri: @redirect_uri,
				scope: Array(@scopes).join(' '),
				response_type: :code
			)

			location = response.headers[:location]
			return location if location

			raise Error, response.body[:message]
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

			response.body
		end

		def validate(access_token:)
			response = CONNECTION.get(
				'validate', {}, { 'Authorization' => "OAuth #{access_token}" }
			)

			response.body
		end

		def refresh(refresh_token:)
			response = CONNECTION.post(
				'token',
				client_id: @client_id,
				client_secret: @client_secret,
				grant_type: :refresh_token,
				refresh_token: refresh_token
			)

			return response.body if response.success?

			raise Error, response.body[:message]
		end
	end
end
