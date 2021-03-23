# frozen_string_literal: true

describe TwitchOAuth2::Client, :vcr do
	subject(:client) do
		described_class.new(
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
					link = client.authorize(scopes: scopes)

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
				expect { result }.to raise_error(
					TwitchOAuth2::UnsupportedTokenTypeError, 'Unsupported token type: `foobar`'
				)
			end
		end
	end

	describe '#validate' do
		subject(:result) do
			client.validate(access_token: access_token)
		end

		let(:actual_access_token) { ENV['TWITCH_ACCESS_TOKEN'] }
		let(:expected_tokens) do
			{
				access_token: expected_access_token,
				refresh_token: expected_refresh_token
			}
		end

		context 'without access token' do
			let(:access_token) { nil }

			it 'returns error' do
				expect(result).to match(
					status: 401, message: 'missing authorization token'
				)
			end
		end

		context 'with actual access token' do
			let(:access_token) { actual_access_token }

			it 'returns the same access token' do
				expect(result).to include(
					client_id: client_id,
					expires_in: be > 0,
					scopes: include(*scopes)
				)
			end
		end

		context 'with outdated access token' do
			let(:access_token) { outdated_access_token }

			it 'returns error' do
				expect(result).to match(
					status: 401, message: 'invalid access token'
				)
			end
		end
	end

	describe '#refresh' do
		subject(:result) { client.refresh(refresh_token: refresh_token) }

		let(:expected_tokens) do
			{
				access_token: expected_access_token,
				refresh_token: expected_refresh_token
			}
		end

		context 'with correct refresh_token' do
			let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

			it 'returns JSON with access_token' do
				expect(result).to include expected_tokens
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
end
