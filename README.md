# TwitchOAuth2

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/twitch_oauth2?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/twitch_oauth2)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/twitch_oauth2/master.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/twitch_oauth2)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/twitch_oauth2.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/twitch_oauth2)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/twitch_oauth2?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/twitch_oauth2)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/twitch_oauth2.svg?branch=master)](https://inch-ci.org/github/AlexWayfer/twitch_oauth2)
[![license](https://img.shields.io/github/license/AlexWayfer/twitch_oauth2.svg?style=flat-square)](https://github.com/AlexWayfer/twitch_oauth2/blob/master/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/twitch_oauth2.svg?style=flat-square)](https://rubygems.org/gems/twitch_oauth2)

Twitch authentication with OAuth 2.
Result tokens can be used for API libraries, chat libraries or something else.

[Twitch Authentication Documentation](https://dev.twitch.tv/docs/authentication)

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

### Initialization

```ruby
require 'twitch_oauth2'

client = TwitchOAuth2::Client.new(
  client_id: 'application_client_id',
  client_secret: 'application_client_secret',
  scopes: %w[user:read:email bits:read] # default is `nil`
  redirect_uri: 'application_redirect_uri' # default is `http://localhost`
)
```

### Check tokens

```ruby
tokens = previously_saved_tokens
# => { access_token: 'abcdef', refresh_token: 'ghikjl' }
# Can be empty.

client.check_tokens **tokens, token_type: :user
```

`:token_type` is optional and is `:application` by default,
but a number of available API end-points is limited in this case.

Also, Application Access Token has no `refresh_token`, but this gem just receive a new one
if a given one is invalid.

#### The first run

You can pass nothing to `#check_tokens`, then client will generate new ones.

If you've specified `:token_type` as `:application` or have not specify it at all (default),
there will be an Application Access Token (without refresh token).

Otherwise, for User Access Token you will be asked to open a Twitch link in a browser
and login as user for whom tokens are intended.

#### Reusing tokens

Then, if you pass tokens, client will validate them and return themselves
or refresh and return new ones.

### Explicitly refresh tokens

You can refresh tokens manually:

```ruby
client.refreshed_tokens refresh_token: 'ghikjl'
```

This is used internally in `#check_tokens`, and can be used separately
for failed requests to API.

And, because Application Access Tokens have no refresh tokens — this method will not work for them.

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/twitch_oauth2).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
