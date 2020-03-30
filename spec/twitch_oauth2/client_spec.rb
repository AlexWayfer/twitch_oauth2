# frozen_string_literal: true

describe TwitchOAuth2::Client do
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

	let(:state) { subject.instance_variable_get(:@state) }
	let(:scope) { scopes.join(' ') }

	describe '#flow' do
		def example_group_descriptions(example_group)
			example_group_description = example_group.description
			return if example_group_description == described_class.name

			[send(__method__, example_group.superclass), example_group_description]
				.compact
		end

		around do |example|
			cassette_name =
				example_group_descriptions(example.example_group)
					.join('/').delete('#').tr(' ', '_')
			VCR.use_cassette(cassette_name) do
				example.run
			end
		end

		let(:vcr_recording?) { VCR.current_cassette.recording? }

		let(:expected_access_token) do
			vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<ACCESS_TOKEN>'
		end

		let(:expected_refresh_token) do
			vcr_recording? ? a_string_matching(/[a-z0-9]{30,}/) : '<REFRESH_TOKEN>'
		end

		let(:expected_token_result) do
			{
				access_token: expected_access_token,
				refresh_token: expected_refresh_token,
				expires_in: a_value > 0,
				scope: scopes.sort,
				token_type: 'bearer'
			}
		end

		context 'without tokens' do
			subject(:result) { client.flow(scopes: scopes) }

			before do
				unless vcr_recording?
					allow(STDIN).to receive(:gets).and_return 'any_code'
				end
			end

			let(:redirect_params) do
				URI.encode_www_form_component URI.encode_www_form(
					client_id: client_id,
					redirect_uri: redirect_uri,
					response_type: :code,
					scope: scope
				)
			end

			let(:expected_result) { expected_token_result }

			let(:expected_instructions) do
				<<~TEXT
					1. Open URL in your browser:
						https://www.twitch.tv/login?client_id=#{client_id}&redirect_params=#{redirect_params}
					2. Login to Twitch.
					3. Copy the `code` parameter from redirected URL.
					4. Insert below:
				TEXT
			end

			it 'returns JSON with access_token' do
				unless vcr_recording?
					allow(STDOUT).to receive(:puts).with(expected_instructions)
				end

				expect(result).to match expected_result
			end

			it 'outputs instructions' do
				expect { result }.to output(expected_instructions).to_stdout
			end
		end

		context 'with actual access_token' do
			subject(:result) { client.flow(access_token: actual_access_token) }

			let(:actual_access_token) { ENV['TWITCH_ACCESS_TOKEN'] }

			let(:expected_result) do
				{
					client_id: client_id,
					expires_in: a_value > 0,
					login: a_string_matching(/\w+/),
					scopes: scopes.sort,
					user_id: a_string_matching(/\d+/)
				}
			end

			it 'returns JSON with access_token' do
				expect(result).to match expected_result
			end
		end

		context 'with outdated access_token' do
			subject(:result) do
				client.flow(
					access_token: outdated_access_token,
					refresh_token: refresh_token
				)
			end

			let(:outdated_access_token) { '9y7bf00r4fof71czggal1e2wlo50q3' }

			context 'with refresh_token' do
				let(:refresh_token) { ENV['TWITCH_REFRESH_TOKEN'] }

				let(:expected_result) { expected_token_result }

				it 'returns JSON with access_token' do
					expect(result).to match expected_result
				end
			end

			context 'without refresh_token' do
				let(:refresh_token) { nil }

				let(:expected_result) do
					{
						status: 400,
						message: 'missing refresh token'
					}
				end

				it 'returns JSON with access_token' do
					expect(result).to match expected_result
				end
			end
		end
	end
end
