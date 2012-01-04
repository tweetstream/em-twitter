require 'spec_helper'

describe EM::Twitter::Request do
  before(:all) do
    @proxy_options = { :proxy => { :uri => 'http://my-proxy:8080', :user => 'username', :password => 'password'} }

    @default_options = {
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

  describe '.new' do
    it 'assigns a proxy if one is set' do
      req = EM::Twitter::Request.new(@proxy_options)
      req.proxy.should be
    end

    it 'overrides defaults' do
      req = EM::Twitter::Request.new(@default_options)
      req.options[:path].should eq('/1/statuses/filter.json')
    end
  end

  describe '#proxy?' do
    it 'defaults to false' do
      req = EM::Twitter::Request.new
      req.proxy?.should be_false
    end

    it 'returns true when a proxy is set' do
      req = EM::Twitter::Request.new(@proxy_options)
      req.proxy?.should be_true
    end
  end

  describe '#to_s' do
    context 'without a proxy' do
      before do
        @request = EM::Twitter::Request.new(@default_options)
      end

      it 'requests the defined path' do
        @request.to_s.should include('/1/statuses/filter.json')
      end

      it 'includes an OAuth header' do
        @request.to_s.should include('Authorization: OAuth')
      end
    end

    context 'when using a proxy' do
      before do
        @request = EM::Twitter::Request.new(@default_options.merge(@proxy_options))
      end

      it 'requests the full uri' do
        @request.to_s.should include('POST https://stream.twitter.com:443/1/statuses/filter.json')
      end

      it 'includes a Proxy header' do
        @request.to_s.should include('Proxy-Authorization: Basic ')
      end
    end

    it 'adds query parameters' do
      @request = EM::Twitter::Request.new(@default_options)
      @request.to_s.should include('track=nfl')
    end

    it 'allows defining a custom user-agent' do
      @request = EM::Twitter::Request.new(@default_options.merge(:user_agent => 'EM::Twitter Test Suite'))
      @request.to_s.should include('User-Agent: EM::Twitter Test Suite')
    end

    it 'adds custom headers' do
      @request = EM::Twitter::Request.new(@default_options.merge(:headers => { 'foo' => 'bar'}))
      @request.to_s.should include('foo: bar')
    end
  end
end