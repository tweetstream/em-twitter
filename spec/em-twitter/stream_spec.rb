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
      it 'connects to the configured host/port' do
        EventMachine.should_receive(:connect).with(test_options[:host], test_options[:port], EventMachine::Twitter::Stream, kind_of(Hash))
        EM::Twitter::Stream.connect(default_options)
      end
    end

    context 'when using a proxy' do
      it 'connects to the proxy server' do
        EventMachine.should_receive(:connect).with("my-proxy", 8080, EventMachine::Twitter::Stream, kind_of(Hash))
        EM::Twitter::Stream.connect(default_options.merge(proxy_options))
      end
    end

    it "should not trigger SSL until connection is established" do
      connection = stub('connection')
      EM.should_receive(:connect).and_return(connection)
      EM.should_not_receive(:start_tls)
      stream = EM::Twitter::Stream.connect(:ssl => true)
      stream.should == connection
    end
  end

  describe '#post_init' do
    it 'calls the on_inited callback' do
      called = false

      EM.run_block do
        client = EM::Twitter::Stream.connect(default_options.merge(:on_inited => lambda { called = true}))
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

  describe 'streaming' do
    before do
      Mockingbird.setup(test_options) do
        on_connection(1) do
          disconnect!
        end

        on_connection(2..5) do
          wait(0.5)
          close
        end

        on_connection('*') do
          100.times do
            send '{"foo":"bar"}'
          end
          close
        end
      end
    end

    after do
      Mockingbird.teardown
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
  end

  describe 'error callbacks' do
    error_callback_invoked('on_unauthorized', 401, 'Unauthorized')
    error_callback_invoked('on_forbidden', 403, 'Forbidden')
    error_callback_invoked('on_not_found', 404, 'Not Found')
    error_callback_invoked('on_not_acceptable', 406, 'Not Acceptable')
    error_callback_invoked('on_too_long', 413, 'Too Long')
    error_callback_invoked('on_range_unacceptable', 416, 'Range Unacceptable')
    error_callback_invoked('on_enhance_your_calm', 420, 'Enhance Your Calm')
  end

  describe 'reconnections' do
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