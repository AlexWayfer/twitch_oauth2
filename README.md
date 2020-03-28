# TwitchOAuth2

Twitch authentication with OAuth 2.
Result tokens can be used for API libraries, chat libraries or something else.

Twitch documentation: https://dev.twitch.tv/docs/authentication

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitch_oauth2'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install twitch_oauth2
```

## Usage

```ruby
require 'twitch_oauth2'
```

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag
for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/AlexWayfer/twitch_oauth2.


## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
