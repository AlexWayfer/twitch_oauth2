# frozen_string_literal: true

require_relative 'authorize_error'

module TwitchOAuth2
	## Class for tokens and their refreshing, using provided client
	class Tokens
		## `refresh_token` for `on_update`, but it can be better to make getter with logic
		## like for `access_token`, but there can be troubles:
		## * right now `refresh_token` is kind of constant, but it can have TTL in the future;
		## * right now there is no `refresh_token` for `:application` tokens, but it can appears
		##   in the future.
		attr_reader :client, :token_type, :refresh_token

		## I don't know how to make it shorter
		# rubocop:disable Metrics/ParameterLists
		def initialize(
			client:, access_token: nil, refresh_token: nil, token_type: :application, scopes: nil,
			on_update: nil
		)
			# rubocop:enable Metrics/ParameterLists
			@client = client.is_a?(Hash) ? Client.new(**client) : client
			@access_token = access_token
			@refresh_token = refresh_token
			@token_type = token_type
			@scopes = scopes
			@on_update = on_update

			@expires_at = nil
		end

		def valid?
			if @access_token
				validate_access_token if @expires_at.nil? || Time.now >= @expires_at
			else
				return false if @token_type == :user

				request_new_tokens
			end

			true
		end

		def authorize_link
			@client.authorize(scopes: @scopes)
		end

		def access_token
			raise AuthorizeError, authorize_link if !valid? && @token_type == :user

			@access_token
		end

		def code=(value)
			assign_tokens @client.token(token_type: @token_type, code: value)
		end

		private

		def validate_access_token
			validate_result = @client.validate access_token: @access_token

			if validate_result[:status] == 401
				refresh_tokens
			elsif (expires_in = validate_result[:expires_in]).positive?
				@expires_at = Time.now + expires_in
			else
				raise "Unexpected validate result: #{validate_result}"
			end
		end

		def refresh_tokens
			case @token_type
			when :user
				assign_tokens @client.refresh(refresh_token: @refresh_token)
			when :application
				request_new_tokens
			else
				raise UnsupportedTokenTypeError, @token_type
			end
		end

		def request_new_tokens
			assign_tokens @client.token(token_type: @token_type)
		end

		def assign_tokens(data)
			@access_token = data[:access_token]
			@refresh_token = data[:refresh_token]
			@expires_at = Time.now + data[:expires_in]

			@on_update&.call(self)
		end
	end
end
