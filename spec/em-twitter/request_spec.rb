require 'spec_helper'

describe EM::Twitter::Request do
  describe ".new" do
    it "assigns a proxy if one is set" do
      req = EM::Twitter::Request.new(proxy_options)
      expect(req.proxy).to be
    end

    it "overrides defaults" do
      req = EM::Twitter::Request.new(default_options)
      expect(req.options[:path]).to eq('/1/statuses/filter.json')
    end
  end

  describe '#oauth_header' do
    it 'passes params on POST requests' do
      options = default_options.merge(:method => 'POST', :host => 'stream.twitter.com', :port => 443)
      req = EM::Twitter::Request.new(options)
      expect(SimpleOAuth::Header).to receive(:new).
        with('POST', "http://stream.twitter.com/1/statuses/filter.json", {"track"=>"nfl"}, kind_of(Hash))

      req.send(:oauth_header)
    end

    it 'passes params on the querystring for GET requests' do
      options = default_options.merge(:method => 'GET', :host => 'stream.twitter.com', :port => 443)
      req = EM::Twitter::Request.new(options)
      expect(SimpleOAuth::Header).to receive(:new).
        with('GET', "http://stream.twitter.com/1/statuses/filter.json?track=nfl", {}, kind_of(Hash))

      req.send(:oauth_header)
    end
  end

  describe "#proxy?" do
    it "defaults to false" do
      req = EM::Twitter::Request.new
      expect(req.proxy?).to be_false
    end

    it "returns true when a proxy is set" do
      req = EM::Twitter::Request.new(proxy_options)
      expect(req.proxy?).to be_true
    end
  end

  describe "#to_s" do
    context "without a proxy" do
      before do
        @request = EM::Twitter::Request.new(default_options)
      end

      it "requests the defined path" do
        expect(@request.to_s).to include('/1/statuses/filter.json')
      end
    end

    context "when using a proxy" do
      before do
        @request = EM::Twitter::Request.new(default_options.merge(proxy_options))
      end

      it "requests the full uri" do
        expect(@request.to_s).to include("POST http://#{test_options[:host]}:#{test_options[:port]}/1/statuses/filter.json")
      end

      it "includes a Proxy header" do
        expect(@request.to_s).to include('Proxy-Authorization: Basic ')
      end
    end

    context "Basic Authentication" do
      before do
        @request = EM::Twitter::Request.new(basic_auth_options)
      end

      it "creates an authorization header" do
        expect(@request.to_s).to include('Authorization: Basic')
      end
    end

    context "gzip encoding" do
      before do
        @request = EM::Twitter::Request.new(default_options.merge(:encoding => 'gzip'))
      end

      it "sets a keep-alive header" do
        expect(@request.to_s).to include('Connection: Keep-Alive')
      end

      it "sets the accept-enconding header" do
        expect(@request.to_s).to include('Accept-Encoding: deflate, gzip')
      end
    end

    it "adds a POST body" do
      @request = EM::Twitter::Request.new(default_options)
      expect(@request.to_s).to include('track=nfl')
    end

    it "adds query parameters" do
      @request = EM::Twitter::Request.new(default_options.merge(:method => :get))
      expect(@request.to_s).to include('/1/statuses/filter.json?track=nfl')
    end

    it "allows defining a custom user-agent" do
      @request = EM::Twitter::Request.new(default_options.merge(:user_agent => 'EM::Twitter Test Suite'))
      expect(@request.to_s).to include('User-Agent: EM::Twitter Test Suite')
    end

    it "adds an accept header" do
      @request = EM::Twitter::Request.new(default_options)
      expect(@request.to_s).to include('Accept: */*')
    end

    it "adds custom headers" do
      @request = EM::Twitter::Request.new(default_options.merge(:headers => { 'foo' => 'bar'}))
      expect(@request.to_s).to include('foo: bar')
    end
  end
end
