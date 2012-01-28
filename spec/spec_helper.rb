require 'simplecov'
$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'em-twitter'
require 'rspec'
require 'mockingbird'

def test_options
  { :host => '127.0.0.1', :port => 9551 }
end

def default_options
  EM::Twitter::DEFAULT_CONNECTION_OPTIONS.merge({
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'nfl'
    },
    :oauth  => {
      :consumer_key     => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret  => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token            => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret     => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    },
    :ssl => false
  }).merge(test_options)
end

def proxy_options
  { :proxy => { :uri => 'http://my-proxy:8080', :user => 'username', :password => 'password'} }
end

def stream_callbacks
  %w(unauthorized forbidden not_found not_acceptable too_long range_unacceptable rate_limited)
end