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

  describe '#post_init' do
    it 'calls the on_inited callback' do
      called = false

      EM.run_block do
        client = EM::Twitter::Stream.connect(default_options.merge(:on_inited => Proc.new { called = true}))
      end

      called.should be_true
    end

    it 'sets the inactivity timeout' do
      EM.should_receive(:set_comm_inactivity_timeout)
      EM.run_block do
        client = EM::Twitter::Stream.connect(default_options.merge(:timeout => 2))
      end
    end
  end

  describe '#receive_data' do
    pending
  end

  describe '#each_item' do
    pending
  end

  describe '#on_error' do
    pending
  end

  describe '#on_unauthorized' do
    pending
  end

  describe '#on_forbidden' do
    pending
  end

  describe '#on_not_found' do
    pending
  end

  describe '#on_not_acceptable' do
    pending
  end

  describe '#on_too_long' do
    pending
  end

  describe '#on_range_unacceptable' do
    pending
  end

  describe '#on_enhance_your_calm' do
    pending
  end

  describe '#on_reconnect' do
    pending
  end

  describe '#on_max_reconnects' do
    pending
  end

  describe "#on_close" do
    it "sets a callback that is invoked when the connection closes" do
      called = false

      EM.run_block do
        client = EM::Twitter::Stream.connect(default_options)
        client.on_close { called = true }
      end

      called.should be_true
    end
  end


end