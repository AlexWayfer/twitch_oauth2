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

Since version `0.4.0`, the main object here is `TwitchOAuth2::Tokens` which receives
and internally uses `client` for necessary requests. This approach allows:

*   get an actual `access_token` with validations, refreshing and other things inside;
*   share and reuse an instance of this class, for example between API and IRC clients;
*   initialize 2 instances for user token and application token, but with the same `client` object.

### Initialization

Client, for requests:

```ruby
require 'twitch_oauth2'

client = TwitchOAuth2::Client.new(
  client_id: 'application_client_id',
  client_secret: 'application_client_secret',
  redirect_uri: 'application_redirect_uri' # default is `http://localhost`
)
```

Tokens, for their storage and refreshing:

```ruby
tokens = TwitchOAuth2::Tokens.new(
  client: client, # initialized above, or can be a `Hash` with values for `Client` initialization
  # all other arguments are optional
  access_token: 'somewhere_received_access_token', # default is `nil`
  refresh_token: 'refresh_token_from_the_same_place', # default is `nil`
  token_type: :user, # default is `:application`
  scopes: %w[user:read:email bits:read] # default is `nil`, but it's not so useful
)
```

### Get tokens

The main method is `Tokens#access_token`: if there is no `access_token` from initialization
or it's incorrect — method will refresh it internally and return the value.

#### The first run

You can pass nothing to `Tokens.new`, then client will generate new ones.

If you've specified `:token_type` as `:application` or have not specify it at all (default),
there will be an Application Access Token (without refresh token).

Otherwise, for User Access Token here will be raised a `TwitchOAuth2::Error` with Twitch link
inside `#metadata[:link]`.

If you have a web-application with N users, you can redirect them to this link
and use `redirect_uri` to your application for callbacks.

Otherwise, if you have something like CLI tool, you can print instructions with a link for user.

Then you can use `tokens.code = 'a code from params in redirect uri'`
and `tokens.access_token` will be available.

#### Reusing tokens

Then, or if you pass tokens to initialization, client will validate them and return themselves
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
