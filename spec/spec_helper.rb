# encoding: utf-8
require 'simplecov'

require 'em-twitter'
require 'rspec'
require 'mockingbird'

def test_options
  { :host => '127.0.0.1', :port => 9551, :quiet => true }
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

def error_callback_invoked(callback, code, desc, msg = nil)
  describe "##{callback}" do
    before do
      Mockingbird.setup(test_options) do
        status code, desc
      end
    end

    after { Mockingbird.teardown }

    it "it invokes the callback on a #{code}" do
      called = false
      if msg
        block = lambda { |m| called = true }
      else
        block = lambda { called = true }
      end

      EM.run do
        client = EM::Twitter::Client.connect(default_options)
        client.send(:"#{callback}", &block)
      end

      called.should be_true
    end
  end
end