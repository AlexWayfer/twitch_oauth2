# frozen_string_literal: true

module TwitchOAuth2
	## Error for `#authorize_link`
	class AuthorizeError < Error
		attr_reader :link

		def initialize(link)
			@link = link
			super('Direct user to `error.link` and assign `code`')
		end
	end
end
