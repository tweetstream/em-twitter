# EM-Twitter
[![Build Status](https://secure.travis-ci.org/spagalloco/em-twitter.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/spagalloco/em-twitter.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/badge.png)][codeclimate]

EM-Twitter is an EventMachine-based ruby client for the [Twitter Streaming API](https://dev.twitter.com/docs/streaming-api).

[travis]: http://travis-ci.org/spagalloco/em-twitter
[gemnasium]: https://gemnasium.com/spagalloco/em-twitter
[codeclimate]: https://codeclimate.com/github/spagalloco/em-twitter

## Usage

```ruby
require 'em-twitter'

options = {
  :path   => '/1/statuses/filter.json',
  :params => { :track => 'yankees' },
  :oauth  => {
    :consumer_key     => ENV['CONSUMER_KEY'],
    :consumer_secret  => ENV['CONSUMER_SECRET'],
    :token            => ENV['OAUTH_TOKEN'],
    :token_secret     => ENV['OAUTH_TOKEN_SECRET']
  }
}

EM.run do
  client = EM::Twitter::Client.connect(options)

  client.each do |result|
    puts result
  end
end
```

## SSL

SSL is used by default (EventMachine defaults to verify_peer => false), and can be configured:

```ruby
options = {
  :ssl => {
    :private_key_file => "path/to/key.pem",
    :cert_chain_file => "path/to/cert.pem",
    :verify_peer => true
  }
}

client = EM::Twitter.Client.connect(options)
```

## Proxy Support

EM-Twitter includes proxy support via a configuration option:

```ruby
options = {
  :proxy => {
    :username => 'myusername',
    :passowrd => 'mypassword',
    :uri => 'http://my-proxy:8080'
  }
}

client = EM::Twitter.Client.connect(options)
```

## Error Handling

EM-Twitter supports the following callbacks for handling errors:

* on_unauthorized
* on_forbidden
* on_not_found
* on_not_acceptable
* on_too_long
* on_range_unacceptable
* on_enhance_your_calm (aliased as on_rate_limited)

Errors callbacks are invoked on a Client like so:

```ruby
client = EM::Twitter.Client.connect(options)
client.on_forbidden do
  puts 'oops'
end
```

## Reconnections

EM-Twitter has two callbacks for reconnection handling:

```ruby
client = EM::Twitter.Client.connect(options)
client.on_reconnect do |timeout, count|
  # called each time the client reconnects
end

client.on_max_reconnects do |timeout, count|
  # called when the client has exceeded either:
  # 1. the maximum number of reconnect attempts
  # 2. the maximum timeout limit for reconnections
end
```

## Todo

* Gzip encoding support (see [issue #1](https://github.com/spagalloco/em-twitter/issues/1) for more information)
* JSON Parser (see [issue #2](https://github.com/spagalloco/em-twitter/issues/2) for more information)

## Inspiration

EM-Twitter is heavily inspired by Vladimir Kolesnikov's [twitter-stream](https://github.com/voloko/twitter-stream).  I learned an incredible amount from studying his code and much of the reconnection handling in EM-Twitter is derived/borrowed from his code as are numerous other bits.  Eloy Durán's [ssalleyware](https://github.com/alloy/ssalleyware) was very helpful in adding SSL Certificate verification as was David Graham's [vines](https://github.com/negativecode/vines).

Testing with EM can be a challenge, but was made incredibly easy through the use of Hayes Davis' awesome [mockingbird](https://github.com/hayesdavis/mockingbird) gem.

## Contributing

Pull requests welcome: fork, make a topic branch, commit (squash when possible) *with tests* and I'll happily consider.

## Copyright

Copyright (c) 2012 Steve Agalloco. See [LICENSE](https://github.com/spagalloco/em-twitter/blob/master/LICENSE.md) for details.
