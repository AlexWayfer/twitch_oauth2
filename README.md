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

### Check tokens

Please, use `Tokens#check_tokens!` method after initialization, especially for empty initial tokens,
especially for User Access Token.

This method will raise an error on any non-valid event.

#### Application Access Token

It's simpler, has less permissions, and it's the default `:token_type`.

Application Access Tokens have no `refresh_token` right now and have longer life time,
so the logic here is simpler: you can pass nothing to `Tokens.new` — the client will generate
new `access_token`, and regenerate when it's will be outdated.

#### User Access Token

If you need for `:user` token and you have no actual `access_token` or `refresh_token`,
**you have to call** `Tokens#check_tokens!`, rescue `TwitchOAuth2::AuthorizeError`
and ask user to open `error.link` in a browser.

After successful user login there will be redirect from Twitch to the `:redirect_uri`
(by default is `localhost`) with the `code` query argument.
You have to pass it to the `Tokens#code=` for `access_token` and `refresh_token` generation,
they will be available right after it.

It's one-time manual operation for User Access Token, further the gem will give you actual tokens
and refresh them as necessary (right now `refresh_token`, getting after `code`, has no life time).

If you have a web-application with N users, you can use `:redirect_uri` argument
for `Client` initialization as your application callback and redirect them to `#authorize_link`.

If you have something like CLI tool, you can print instructions for user
inside rescuing `TwitchOAuth2::AuthorizeError`.

Without checking tokens the same error will be raised on try to access `#access_token`,
and it can interrupt some operations, like API library initialization.

The reference for such behavior is [the official Google API gem](https://github.com/googleapis/google-api-ruby-client/blob/39ae3527722a003b389a2f7f5275ab9c6e93bb5e/samples/cli/lib/base_cli.rb`),
but more exception-oriented, because there are too much possible reasons for unexpected behavior,
like wrong client ID, wrong refresh token, something else.

Another reference, [`twitch` package for JavaScript](https://d-fischer.github.io/twitch/),
has refreshing logic, but [requires initial correct tokens from you](https://d-fischer.github.io/twitch-chat-client/docs/examples/basic-bot.html),
and doesn't care how you'll get them.


### Get tokens

The main method is `Tokens#access_token`: it's used in API libraries, in chat libraries, etc.

It has refreshing logic inside for cases when it's outdated.
But if there is no initial `refresh_token` — be aware and read the documentation below.

There is also `#refresh_token` getter, just for storing it or something else,
it's more important internally.

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
