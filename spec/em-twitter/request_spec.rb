require 'spec_helper'

describe EM::Twitter::Request do
  describe '.new' do
    it 'assigns a proxy if one is set' do
      req = EM::Twitter::Request.new(proxy_options)
      req.proxy.should be
    end

    it 'overrides defaults' do
      req = EM::Twitter::Request.new(default_options)
      req.options[:path].should eq('/1/statuses/filter.json')
    end
  end

  describe '#proxy?' do
    it 'defaults to false' do
      req = EM::Twitter::Request.new
      req.proxy?.should be_false
    end

    it 'returns true when a proxy is set' do
      req = EM::Twitter::Request.new(proxy_options)
      req.proxy?.should be_true
    end
  end

  describe '#to_s' do
    context 'without a proxy' do
      before do
        @request = EM::Twitter::Request.new(default_options)
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
        @request = EM::Twitter::Request.new(default_options.merge(proxy_options))
      end

      it 'requests the full uri' do
        @request.to_s.should include("POST https://#{test_options[:host]}:#{test_options[:port]}/1/statuses/filter.json")
      end

      it 'includes a Proxy header' do
        @request.to_s.should include('Proxy-Authorization: Basic ')
      end
    end

    it 'adds query parameters' do
      @request = EM::Twitter::Request.new(default_options)
      @request.to_s.should include('track=nfl')
    end

    it 'allows defining a custom user-agent' do
      @request = EM::Twitter::Request.new(default_options.merge(:user_agent => 'EM::Twitter Test Suite'))
      @request.to_s.should include('User-Agent: EM::Twitter Test Suite')
    end

    it 'adds custom headers' do
      @request = EM::Twitter::Request.new(default_options.merge(:headers => { 'foo' => 'bar'}))
      @request.to_s.should include('foo: bar')
    end
  end
end