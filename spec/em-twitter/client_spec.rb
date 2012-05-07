require 'spec_helper'

describe EM::Twitter::Client do

  describe '.connect' do
    before do
      conn = stub('EventMachine::Connection')
      conn.stub(:start_tls).and_return(nil)
      EM.stub(:connect).and_return(conn)
    end

    context 'without a proxy' do
      it 'connects to the configured host/port' do
        EventMachine.should_receive(:connect).with(test_options[:host], test_options[:port], EventMachine::Twitter::Connection, kind_of(EM::Twitter::Client))
        EM::Twitter::Client.connect(default_options)
      end
    end

    context 'when using a proxy' do
      it 'connects to the proxy server' do
        EventMachine.should_receive(:connect).with("my-proxy", 8080, EventMachine::Twitter::Connection, kind_of(EM::Twitter::Client))
        EM::Twitter::Client.connect(default_options.merge(proxy_options))
      end
    end

    it "should not trigger SSL until connection is established" do
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
        client.respond_to?(:reset).should be_true
      end
    end
  end

end