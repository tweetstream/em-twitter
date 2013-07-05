# encoding: utf-8
unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_group 'EM-Twitter', 'lib/em-twitter'
    add_group 'Specs', 'spec'
    add_filter '.bundle'
  end
end

require 'em-twitter'
require 'rspec'
require 'mockingbird'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

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

def basic_auth_options
  opts = default_options.dup
  opts.delete(:oauth)
  opts.merge(:basic => { :username => 'Steve', :password => 'Agalloco' })
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
      response_code = nil

      block = if msg
        lambda do |resp_code|
          response_code = resp_code
          called = true
          EM.stop
        end
      else
        lambda do
          called = true
          EM.stop
        end
      end

      EM.run do
        client = EM::Twitter::Client.connect(default_options)
        client.send(:"#{callback}", &block)
      end

      expect(response_code).to eq("Unhandled status code: #{code}.") if response_code
      expect(called).to be_true
    end
  end
end
