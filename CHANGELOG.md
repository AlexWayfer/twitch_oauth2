# Changelog

## Unreleased

## 0.5.0 (2023-07-25)

*   Introduce `Tokens` object.
    It stores access and refresh tokens, also calls `client` for interactions with them,
    like refreshing.
    This approach allows to share this object with the same tokens between different libraries
    and storing (and refreshing) tokens in (temporary, secret) file.
*   Add Ruby 3.2 to CI.
*   Drop Ruby 2.6 support.
*   Update development dependencies.
*   Improve CI.

## 0.4.0 (2022-07-23)

*   Support Ruby 3.
*   Drop Ruby 2.5 support.
*   Update Faraday to version 2.
*   Resolve new RuboCop offenses.
*   Update development dependencies.

## 0.3.0 (2020-12-05)

*   Raise an error for `:user` token type with a login link inside
    See [this discussion](https://github.com/mauricew/ruby-twitch-api/pull/22#discussion_r526518859).
*   Update (development) dependencies.

## 0.2.0 (2020-11-05)

*   Add an ability to generate Application tokens.
    Useful for the actual, Helix, Twitch API.
*   Update dependencies.

## 0.1.0 (2020-05-23)

*   Initial release
