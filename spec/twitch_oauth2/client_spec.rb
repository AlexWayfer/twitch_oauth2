# frozen_string_literal: true

describe TwitchOAuth2::Client, :vcr do
	subject(:client) do
		described_class.new(
			client_id: client_id,
			client_secret: client_secret,
			redirect_uri: redirect_uri,
			scopes: scopes
		)
	end

	let(:client_id) { ENV['TWITCH_CLIENT_ID'] }
	let(:client_secret) { ENV['TWITCH_CLIENT_SECRET'] }
	let(:redirect_uri) { 'http://localhost' }
	let(:scopes) { %w[user:read:email bits:read] }

	let(:outdated_access_token) { '9y7bf00r4fof71czggal1e2wlo50q3' }

	let(:state) { subject.instance_variable_get(:@state) }
	let(:scope) { scopes.join(' ') }
	let(:vcr_recording?) { VCR.current_cassette.recording? }

	let(:expected_access_token) do
		vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<ACCESS_TOKEN>'
	end

	let(:expected_refresh_token) do
		vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<REFRESH_TOKEN>'
	end

	describe '#check_tokens' do
		subject(:result) do
			client.check_tokens(
				access_token: access_token, refresh_token: refresh_token, token_type: token_type
			)
		end

		context 'when `token_type` is `user`' do
			let(:token_type) { :user }
			let(:actual_access_token) { ENV['TWITCH_ACCESS_TOKEN'] }
			let(:expected_tokens) do
				{
					access_token: expected_access_token,
					refresh_token: expected_refresh_token
				}
			end

			context 'without tokens' do
				let(:access_token) { nil }
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
					expect { result }.to raise_error an_instance_of(TwitchOAuth2::Error)
						.and having_attributes(
							message: 'Use `error.metadata[:link]` for getting new tokens',
							metadata: { link: expected_link }
						)
				end
			end

			context 'with actual access token' do
				let(:access_token) { actual_access_token }
				let(:refresh_token) { 42 }

				it 'returns the same tokens' do
					expect(result).to match(
						access_token: access_token, refresh_token: refresh_token
					)
				end
			end

			context 'with outdated access token' do
				let(:access_token) { outdated_access_token }

				context 'with refresh token' do
					let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

					it 'returns JSON with access_token' do
						expect(result).to match expected_tokens
					end
				end

				context 'without refresh token' do
					let(:refresh_token) { nil }

					it 'raises error' do
						expect { result }
							.to raise_error TwitchOAuth2::Error, 'missing refresh token'
					end
				end
			end
		end

		context 'when `token_type` is `application`' do
			let(:token_type) { :application }
			let(:refresh_token) { nil }
			let(:actual_access_token) { ENV['TWITCH_APPLICATION_ACCESS_TOKEN'] }
			let(:expected_tokens) do
				{
					access_token: expected_access_token
				}
			end

			context 'without access token' do
				let(:access_token) { nil }

				context 'with correct client credentials' do
					it 'returns new tokens' do
						expect(result).to match expected_tokens
					end
				end

				context 'with incorrect client credentials' do
					let(:client_id) { nil }
					let(:client_secret) { nil }

					it 'raises error' do
						expect { result }.to raise_error TwitchOAuth2::Error, 'missing client id'
					end
				end
			end

			context 'with actual access token' do
				let(:access_token) { actual_access_token }

				it 'returns the same access token' do
					expect(result).to match(access_token: access_token, refresh_token: refresh_token)
				end
			end

			context 'with outdated access token' do
				let(:access_token) { outdated_access_token }

				it 'returns new tokens' do
					expect(result).to match expected_tokens
				end
			end
		end

		context 'when `token_type` is unsupported' do
			let(:token_type) { :foobar }
			let(:access_token) { 'foo' }
			let(:refresh_token) { 'bar' }

			it 'raises error' do
				expect { result }.to raise_error TwitchOAuth2::Error, 'unsupported token type'
			end
		end
	end

	describe '#refreshed_tokens' do
		subject(:result) { client.refreshed_tokens(refresh_token: refresh_token) }

		let(:expected_tokens) do
			{
				access_token: expected_access_token,
				refresh_token: expected_refresh_token
			}
		end

		context 'with correct refresh_token' do
			let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

			it 'returns JSON with access_token' do
				expect(result).to match expected_tokens
			end
		end

		context 'with incorrect refresh_token' do
			let(:refresh_token) { 'foobar' }

			it 'raises error' do
				expect { result }
					.to raise_error TwitchOAuth2::Error, 'Invalid refresh token'
			end
		end

		context 'without refresh_token' do
			let(:refresh_token) { nil }

			it 'raises error' do
				expect { result }
					.to raise_error TwitchOAuth2::Error, 'missing refresh token'
			end
		end
	end

	describe '#token' do
		subject(:result) { client.token(token_type: token_type, code: code) }

		context 'when `token_type` is `user`' do
			let(:token_type) { :user }

			let(:expected_tokens) do
				{
					access_token: expected_access_token,
					refresh_token: expected_refresh_token
				}
			end

			context 'without code' do
				let(:code) { nil }

				it 'raises an error' do
					expect { result }.to raise_error TwitchOAuth2::Error, 'missing code'
				end
			end

			context 'with code' do
				let(:code) do
					return 'any_code' unless vcr_recording?

					client.check_tokens(token_type: token_type, access_token: nil, refresh_token: nil)
				rescue TwitchOAuth2::Error => e
					raise e unless (link = e.metadata[:link])

					puts <<~TEXT

						Please, open this link:

							#{link}

						authorize, and paste here `code` param from redirected `localhost` URL.
					TEXT

					gets.chomp
				end

				let(:refresh_token) { 42 }

				it 'returns new tokens' do
					expect(result).to include expected_tokens
				end
			end
		end

		context 'when `token_type` is `application`' do
			let(:token_type) { :application }
			let(:code) { nil }

			let(:expected_tokens) do
				{
					access_token: expected_access_token
				}
			end

			context 'with correct client credentials' do
				it 'returns new tokens' do
					expect(result).to include expected_tokens
				end
			end

			context 'with incorrect client credentials' do
				let(:client_id) { nil }
				let(:client_secret) { nil }

				it 'raises error' do
					expect { result }.to raise_error TwitchOAuth2::Error, 'missing client id'
				end
			end
		end

		context 'when `token_type` is unsupported' do
			let(:token_type) { :foobar }
			let(:code) { nil }

			it 'raises error' do
				expect { result }.to raise_error TwitchOAuth2::Error, 'unsupported token type'
			end
		end
	end
end
