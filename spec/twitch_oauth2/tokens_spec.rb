# frozen_string_literal: true

describe TwitchOAuth2::Tokens, :vcr do
	subject(:tokens) do
		described_class.new(
			client: client,
			access_token: initial_access_token,
			refresh_token: refresh_token,
			token_type: token_type,
			scopes: scopes
		)
	end

	let(:client) do
		TwitchOAuth2::Client.new(
			client_id: client_id,
			client_secret: client_secret,
			redirect_uri: redirect_uri
		)
	end

	let(:client_id) { ENV['TWITCH_CLIENT_ID'] }
	let(:client_secret) { ENV['TWITCH_CLIENT_SECRET'] }
	let(:redirect_uri) { 'http://localhost' }
	let(:scopes) { %w[user:read:email bits:read] }

	let(:outdated_access_token) { '9y7bf00r4fof71czggal1e2wlo50q3' }

	let(:scope) { scopes.join(' ') }
	let(:vcr_recording?) { VCR.current_cassette.recording? }

	let(:expected_access_token) do
		vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<ACCESS_TOKEN>'
	end

	let(:expected_refresh_token) do
		vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<REFRESH_TOKEN>'
	end

	describe '#access_token' do
		subject(:access_token) { tokens.access_token }

		context 'when `token_type` is `user`' do
			let(:token_type) { :user }
			let(:actual_access_token) { ENV['TWITCH_ACCESS_TOKEN'] }

			context 'without initial tokens' do
				let(:initial_access_token) { nil }
				let(:refresh_token) { nil }

				let(:redirect_params) do
					URI.encode_www_form_component URI.encode_www_form(
						client_id: client_id,
						redirect_uri: redirect_uri,
						response_type: :code,
						scope: scope
					)
				end

				let(:expected_link) do
					"https://www.twitch.tv/login?client_id=#{client_id}&redirect_params=#{redirect_params}"
				end

				it 'raises an error with link' do
					expect { access_token }.to raise_error an_instance_of(TwitchOAuth2::Error)
						.and having_attributes(
							message: 'Use `error.metadata[:link]` for getting new tokens',
							metadata: { link: expected_link }
						)
				end
			end

			context 'with actual initial access token' do
				let(:initial_access_token) { actual_access_token }
				let(:refresh_token) { 42 }

				it 'returns the same access token' do
					expect(access_token).to eq initial_access_token
				end
			end

			context 'with outdated initial access token' do
				let(:initial_access_token) { outdated_access_token }

				context 'with refresh token' do
					let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

					it 'returns new access token' do
						expect(access_token).to match expected_access_token
					end
				end

				context 'without refresh token' do
					let(:refresh_token) { nil }

					it 'raises error' do
						expect { access_token }.to raise_error TwitchOAuth2::Error, 'missing refresh token'
					end
				end
			end
		end

		context 'when `token_type` is `application`' do
			let(:token_type) { :application }
			let(:refresh_token) { nil }
			let(:actual_access_token) { ENV['TWITCH_APPLICATION_ACCESS_TOKEN'] }

			context 'without initial access token' do
				let(:initial_access_token) { nil }

				context 'with correct client credentials' do
					it 'returns new access token' do
						expect(access_token).to match expected_access_token
					end
				end

				context 'with incorrect client credentials' do
					let(:client_id) { nil }
					let(:client_secret) { nil }

					it 'raises error' do
						expect { access_token }.to raise_error TwitchOAuth2::Error, 'missing client id'
					end
				end
			end

			context 'with actual initial access token' do
				let(:initial_access_token) { actual_access_token }

				it 'returns the same access token' do
					expect(access_token).to eq initial_access_token
				end
			end

			context 'with outdated initial access token' do
				let(:initial_access_token) { outdated_access_token }

				it 'returns new tokens' do
					expect(access_token).to match expected_access_token
				end
			end
		end

		context 'when `token_type` is unsupported' do
			let(:token_type) { :foobar }
			let(:initial_access_token) { 'foo' }
			let(:refresh_token) { 'bar' }

			it 'raises error' do
				expect { access_token }.to raise_error(
					TwitchOAuth2::UnsupportedTokenTypeError, 'Unsupported token type: `foobar`'
				)
			end
		end
	end

	describe '#code=' do
		subject(:code_assignment) do
			tokens.code = code
		end

		let(:access_token) { tokens.access_token }

		let(:initial_access_token) { nil }
		let(:refresh_token) { nil }

		context 'when `token_type` is `user`' do
			let(:token_type) { :user }

			context 'without code' do
				let(:code) { nil }

				it 'raises an error' do
					expect { code_assignment }.to raise_error TwitchOAuth2::Error, 'missing code'
				end
			end

			context 'with code' do
				let(:code) do
					client.flow(token_type: token_type, scopes: scopes)
				rescue TwitchOAuth2::Error => e
					raise e unless (link = e.metadata[:link])

					return 'any_code' unless vcr_recording?

					puts <<~TEXT

						Please, open this link:

							#{link}

						authorize, and paste here `code` param from redirected `localhost` URL.
					TEXT

					$stdin.gets.chomp
				end

				let(:refresh_token) { 42 }

				it 'returns new tokens' do
					code_assignment
					expect(access_token).to match expected_access_token
				end
			end
		end

		context 'when `token_type` is `application`' do
			let(:token_type) { :application }
			let(:code) { nil }

			context 'with correct client credentials' do
				it 'returns new tokens' do
					code_assignment
					expect(access_token).to match expected_access_token
				end
			end

			context 'with incorrect client credentials' do
				let(:client_id) { nil }
				let(:client_secret) { nil }

				it 'raises error' do
					expect { code_assignment }.to raise_error TwitchOAuth2::Error, 'missing client id'
				end
			end
		end

		context 'when `token_type` is unsupported' do
			let(:token_type) { :foobar }
			let(:code) { nil }

			it 'raises error' do
				expect { code_assignment }.to raise_error(
					TwitchOAuth2::UnsupportedTokenTypeError, 'Unsupported token type: `foobar`'
				)
			end
		end
	end
end
