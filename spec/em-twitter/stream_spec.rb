require 'spec_helper'

describe EM::Twitter::Stream do

  describe '.new' do
  end

  describe '.connect' do
    before do
      conn = stub('EventMachine::Connection')
      conn.stub(:start_tls).and_return(nil)
      EM.stub(:connect).and_return(conn)
    end

    context 'without a proxy' do
      it 'connects to twitter' do
        EventMachine.should_receive(:connect).with("stream.twitter.com", 443, EventMachine::Twitter::Stream, kind_of(Hash))
        EM::Twitter::Stream.connect(default_options)
      end
    end

    context 'when using a proxy' do
      it 'connects to the proxy server' do
        EventMachine.should_receive(:connect).with("my-proxy", 8080, EventMachine::Twitter::Stream, kind_of(Hash))
        EM::Twitter::Stream.connect(default_options.merge(proxy_options))
      end
    end

  end
end