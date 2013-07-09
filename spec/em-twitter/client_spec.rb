require 'spec_helper'

describe EM::Twitter::Client do

  describe "initialization" do
    it "raises a ConfigurationError if both oauth and basic are used" do
      opts = default_options.merge(:basic => { :username => 'Steve', :password => 'Agalloco' })
      expect{
        EM::Twitter::Client.new(opts)
      }.to raise_error(EM::Twitter::ConfigurationError)
    end
  end

  describe ".connect" do
    before do
      conn = double('EventMachine::Connection')
      allow(conn).to receive(:start_tls).and_return(nil)
      allow(EM).to receive(:connect).and_return(conn)
    end

    it "connects to the configured host/port" do
      expect(EventMachine).to receive(:connect).with(
        test_options[:host],
        test_options[:port],
        EventMachine::Twitter::Connection,
        kind_of(EM::Twitter::Client),
        test_options[:host],
        test_options[:port])
      EM::Twitter::Client.connect(default_options)
    end

    context "when using a proxy" do
      it "connects to the proxy server" do
        expect(EventMachine).to receive(:connect).with(
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
      connection = double('EventMachine::Connection')
      expect(EM).to receive(:connect).and_return(connection)
      expect(EM).not_to receive(:start_tls)
      client = EM::Twitter::Client.connect(:ssl => { :key => "/path/to/key.pem", :cert => "/path/to/cert.pem" })
    end
  end

  describe "#respond_to?" do
    it "delegate to the connection" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        expect(client.respond_to?(:immediate_reconnect)).to be_true
      end
    end
  end

end
