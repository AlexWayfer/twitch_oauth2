# frozen_string_literal: true

module TwitchOAuth2
	## Class for tokens and their refreshing, using provided client
	class Tokens
		attr_reader :client, :token_type

		def initialize(
			client:, access_token: nil, refresh_token: nil, token_type: :application, scopes: nil
		)
			@client = client.is_a?(Hash) ? Client.new(**client) : client
			@access_token = access_token
			@refresh_token = refresh_token
			@token_type = token_type
			@scopes = scopes

			@expires_at = nil
		end

		def access_token
			if @access_token
				validate_access_token if @expires_at.nil? || Time.now >= @expires_at
			else
				request_new_tokens
			end

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
			assign_tokens @client.flow token_type: @token_type, scopes: @scopes
		end

		def assign_tokens(data)
			@access_token = data[:access_token]
			@refresh_token = data[:refresh_token]
			@expires_at = Time.now + data[:expires_in]
		end
	end
end
