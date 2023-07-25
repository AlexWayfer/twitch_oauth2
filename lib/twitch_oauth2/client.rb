# frozen_string_literal: true

require 'faraday'
require 'faraday/parse_dates'
require 'securerandom'

module TwitchOAuth2
	## Client for making requests
	class Client
		CONNECTION = Faraday.new(
			url: 'https://id.twitch.tv/oauth2/'
		) do |connection|
			connection.request :json

			connection.response :parse_dates

			connection.response :json,
				content_type: /\bjson$/,
				parser_options: { symbolize_names: true }
		end.freeze

		attr_reader :client_id

		def initialize(client_id:, client_secret:, redirect_uri: 'http://localhost')
			@client_id = client_id
			@client_secret = client_secret
			@redirect_uri = redirect_uri
		end

		def authorize(scopes:)
			response = CONNECTION.get(
				'authorize',
				client_id: @client_id,
				redirect_uri: @redirect_uri,
				scope: Array(scopes).join(' '),
				response_type: :code
			)

			location = response.headers[:location]
			return location if location

			raise Error, response.body[:message]
		end

		def token(token_type:, code: nil)
			response = CONNECTION.post(
				'token',
				client_id: @client_id,
				client_secret: @client_secret,
				code: code,
				grant_type: grant_type_by_token_type(token_type),
				redirect_uri: @redirect_uri
			)

			return response.body if response.success?

			raise Error, response.body[:message]
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

		private

		def grant_type_by_token_type(token_type)
			case token_type
			when :user then :authorization_code
			when :application then :client_credentials
			else raise UnsupportedTokenTypeError, token_type
			end
		end
	end
end
