# frozen_string_literal: true

module TwitchOAuth2
	## Error during Twitch OAuth2 operations
	class Error < StandardError
		attr_reader :metadata

		def initialize(message, metadata = {})
			super message

			@metadata = metadata
		end
	end
end
