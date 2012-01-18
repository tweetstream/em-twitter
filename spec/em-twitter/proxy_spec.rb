require 'spec_helper'

describe EM::Twitter::Proxy do
  describe '.new' do
    it 'interprets a proxy configuration' do
      proxy = EM::Twitter::Proxy.new(proxy_options[:proxy])
      proxy.user.should eq('username')
      proxy.password.should eq('password')
      proxy.uri.should eq('http://my-proxy:8080')
    end
  end

  describe '#header' do
    it 'returns false when no proxy credentials are passed' do
      EM::Twitter::Proxy.new.header.should be_false
    end

    it 'generates a header when passed credentials' do
      proxy = EM::Twitter::Proxy.new(proxy_options[:proxy])
      proxy.header.should be
    end
  end
end