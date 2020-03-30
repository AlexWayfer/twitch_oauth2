# TwitchOAuth2

Twitch authentication with OAuth 2.
Result tokens can be used for API libraries, chat libraries or something else.

[Twitch Authentication Documentation]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitch_oauth2'
```

And then execute:

```
bundle install
```

Or install it yourself as:

```
gem install twitch_oauth2
```

## Usage

```ruby
require 'twitch_oauth2'

client = TwitchOAuth2::Client.new(
  client_id: 'application_client_id',
  client_secret: 'application_client_secret',
  ## Optional:
  # redirect_uri: 'application_redirect_uri' ## default is `http://localhost`
  # scopes: %w[user:read:email bits:read] ## default is `nil`
)
```

### The first run

(you will be asked to open a Twitch link in a browser
and login as user for whom tokens are intended)

```ruby
## `scopes` can be passed only to `initialize`
client.flow scopes: %w[user:read:email bits:read]

# {
#   access_token: 'abcdef',
#   refresh_token: 'ghikjl',
#   expires_in: 15_000,
#   scope: %w[bits:read user:read:email],
#   token_type: 'bearer'
# }
```

### Reusing existing `access_token`

```ruby
client.flow access_token: 'abcdef', refresh_token: 'ghikjl'

## Successful validation without refreshing

# {
#   client_id: 'application_client_id',
#   expires_in: 14_990,
#   login: 'login_of_access_token_user',
#   scopes: %w[bits:read user:read:email],
#   user_id: 'id_of_access_token_user'
# }

## `access_token` was expired and refreshed via `refresh_token`

# {
#   access_token: 'a_new_access_token',
#   refresh_token: 'a_new_refresh_token',
#   expires_in: 15_000,
#   scope: %w[bits:read user:read:email],
#   token_type: 'bearer'
# }
```

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rake spec` to run the tests.

We're using [VCR](https://relishapp.com/vcr/vcr/docs) cassettes
with filtered sensitive data, so you don't need for real credentials
(like Twitch Client ID and Client Secret) for changing existing methods,
but you need for them to add new requests.
You can read how to get them [here][Twitch Authentication Documentation].

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag
for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/twitch_oauth2).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

[Twitch Authentication Documentation]: https://dev.twitch.tv/docs/authentication
