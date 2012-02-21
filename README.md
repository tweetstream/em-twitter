# EM-Twitter

EM-Twitter is a ruby client for the Twitter Streaming API.  It uses EventMachine.

## Usage

## SSL

SSL is on by default, and can be configured:

    options = {
      :ssl => {
        :private_key_file => "path/to/key.pem",
        :cert_chain_file => "path/to/cert.pem",
        :verify_peer => true
      }
    }

    client = EM::Twitter.Client.connect(options)

## Proxy Support

EM-Twitter includes proxy support via a configuration option:

    options = {
      :proxy => {
        :username => 'myusername',
        :passowrd => 'mypassword',
        :uri => 'http://my-proxy:8080'
      }
    }

    client = EM::Twitter.Client.connect(options)

## Error Handling

EM-Twitter supports the following callbacks for handling errors:

* unauthorized
* forbidden
* not_found
* not_acceptable
* too_long
* range_unacceptable
* enhance_your_calm (aliased as rate_limited)

Errors callbacks are invoked on a Client like so:

    client = EM::Twitter.Client.connect(options)
    client.forbidden do
      puts 'oops'
    end

## Todo

* Gzip encoding support (see [issue #1](https://github.com/spagalloco/em-twitter/issues/1) for more information)
* JSON Parser (see [issue #2](https://github.com/spagalloco/em-twitter/issues/2) for more information)

## Inspiration

EM-Twitter is heavily inspired by Vladimir Kolesnikov's [twitter-stream](https://github.com/voloko/twitter-stream).  I learned an incredible amount from studying his code and much of the reconnection handling in EM-Twitter is derived/borrowed from him.  Eloy Durán's [ssalleyware](https://github.com/alloy/ssalleyware) was very helpful in adding SSL Certificate verification as was David Graham's [vines](https://github.com/negativecode/vines).

Testing with EM can be a challenge, but was made incredibly easy through the use of Hayes Davis' awesome [mockingbird](https://github.com/hayesdavis/mockingbird) gem.

## Contributing

Pull requests welcome: fork, make a topic branch, commit (squash when possible) *with tests* and I'll happily consider.

## Copyright

Copyright (c) 2012 Steve Agalloco. See [LICENSE](https://github.com/spagalloco/em-twitter/blob/master/LICENSE.md) for detail
