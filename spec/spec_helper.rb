$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'em-twitter'
require 'rspec'

def default_options
  {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'nfl'
    },
    :oauth  => {
      :consumer_key     => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret  => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token            => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret     => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    }
  }
end

def proxy_options
  { :proxy => { :uri => 'http://my-proxy:8080', :user => 'username', :password => 'password'} }
end