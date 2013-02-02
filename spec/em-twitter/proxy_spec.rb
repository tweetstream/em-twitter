require 'spec_helper'

describe EM::Twitter::Proxy do
  describe ".new" do
    it "interprets a proxy configuration" do
      proxy = EM::Twitter::Proxy.new(proxy_options[:proxy])
      expect(proxy.user).to eq('username')
      expect(proxy.password).to eq('password')
      expect(proxy.uri).to eq('http://my-proxy:8080')
    end
  end

  describe "#header" do
    it "returns false when no proxy credentials are passed" do
      expect(EM::Twitter::Proxy.new.header).to be_false
    end

    it "generates a header when passed credentials" do
      proxy = EM::Twitter::Proxy.new(proxy_options[:proxy])
      expect(proxy.header).to be
    end
  end
end
