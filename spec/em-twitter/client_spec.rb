require 'spec_helper'

describe EM::Twitter::Client do

  describe 'initialization' do
    it 'raises a ConfigurationError if both oauth and basic are used' do
      opts = default_options.merge(:basic => { :username => 'Steve', :password => 'Agalloco' })
      lambda {
        EM::Twitter::Client.new(opts)
      }.should raise_error(EM::Twitter::ConfigurationError)
    end

    it 'merges default request parameters' do
      client = EM::Twitter::Client.new(default_options)
      client.options[:params].should include(:stall_warnings => 'true')
    end
  end

  describe '.connect' do
    before do
      conn = stub('EventMachine::Connection')
      conn.stub(:start_tls).and_return(nil)
      EM.stub(:connect).and_return(conn)
    end

    it 'connects to the configured host/port' do
      EventMachine.should_receive(:connect).with(
        test_options[:host],
        test_options[:port],
        EventMachine::Twitter::Connection,
        kind_of(EM::Twitter::Client),
        test_options[:host],
        test_options[:port])
      EM::Twitter::Client.connect(default_options)
    end

    context 'when using a proxy' do
      it 'connects to the proxy server' do
        EventMachine.should_receive(:connect).with(
          "my-proxy",
          8080,
          EventMachine::Twitter::Connection,
          kind_of(EM::Twitter::Client),
          'my-proxy',
          8080)
        EM::Twitter::Client.connect(default_options.merge(proxy_options))
      end
    end

    it "doesn't trigger SSL until connection is established" do
      connection = stub('EventMachine::Connection')
      EM.should_receive(:connect).and_return(connection)
      EM.should_not_receive(:start_tls)
      client = EM::Twitter::Client.connect(:ssl => { :key => "/path/to/key.pem", :cert => "/path/to/cert.pem" })
    end
  end

  describe '#respond_to?' do
    it 'delegate to the connection' do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.respond_to?(:immediate_reconnect).should be_true
      end
    end
  end

end
