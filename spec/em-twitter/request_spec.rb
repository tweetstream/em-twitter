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
    end

    context 'when using a proxy' do
      before do
        @request = EM::Twitter::Request.new(default_options.merge(proxy_options))
      end

      it 'requests the full uri' do
        @request.to_s.should include("POST http://#{test_options[:host]}:#{test_options[:port]}/1/statuses/filter.json")
      end

      it 'includes a Proxy header' do
        @request.to_s.should include('Proxy-Authorization: Basic ')
      end
    end

    context 'Basic Authentication' do
      before do
        @request = EM::Twitter::Request.new(basic_auth_options)
      end

      it 'creates an authorization header' do
        @request.to_s.should include('Authorization: Basic')
      end
    end

    context 'gzip encoding' do
      before do
        @request = EM::Twitter::Request.new(default_options.merge(:encoding => 'gzip'))
      end

      it 'sets a keep-alive header' do
        @request.to_s.should include('Connection: Keep-Alive')
      end

      it 'sets the accept-enconding header' do
        @request.to_s.should include('Accept-Encoding: deflate, gzip')
      end
    end

    it 'adds a POST body' do
      @request = EM::Twitter::Request.new(default_options)
      @request.to_s.should include('track=nfl')
    end

    it 'adds query parameters' do
      @request = EM::Twitter::Request.new(default_options.merge(:method => :get))
      @request.to_s.should include('/1/statuses/filter.json?track=nfl')
    end

    it 'allows defining a custom user-agent' do
      @request = EM::Twitter::Request.new(default_options.merge(:user_agent => 'EM::Twitter Test Suite'))
      @request.to_s.should include('User-Agent: EM::Twitter Test Suite')
    end

    it 'adds an accept header' do
      @request = EM::Twitter::Request.new(default_options)
      @request.to_s.should include('Accept: */*')
    end

    it 'adds custom headers' do
      @request = EM::Twitter::Request.new(default_options.merge(:headers => { 'foo' => 'bar'}))
      @request.to_s.should include('foo: bar')
    end
  end
end