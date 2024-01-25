# frozen_string_literal: true

module TwitchOAuth2
	## Error with `:token_type` recognition
	class UnsupportedTokenTypeError < Error
		def initialize(token_type)
			super("Unsupported token type: `#{token_type}`")
		end
	end
end
