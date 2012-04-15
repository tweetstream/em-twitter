require 'spec_helper'

describe 'EM::Twitter::Client reconnections' do

  describe '#reconnect' do
    before do
      Mockingbird.setup(test_options) do
        on_connection(1) do
          disconnect!
        end
      end
    end

    after { Mockingbird.teardown }

    it 'calls the on_reconnect callback on reconnects' do
      pending
      # called = false
      #
      # EM.run do
      #   client = EM::Twitter::Client.connect(default_options)
      #   client.on_reconnect { called = true; EM.stop }
      # end
      #
      # called.should be_true
    end

    it 'does not reconnect when auto_reconnect is false' do
      EM.run do
        client = EM::Twitter::Client.connect(default_options)
        client.should_not_receive(:reconnect)
        client.on_close { EM.stop }
      end
    end
  end

  describe '#immediate_reconnect' do
    before do
      Mockingbird.setup(test_options) do
        100.times do
          send '{"foo":"bar"}'
        end
      end
    end

    after { Mockingbird.teardown }

    it 'reconnects immediately' do
      pending
      # called = false
      #
      # EM.run_block do
      #   client = EM::Twitter::Client.connect(default_options)
      #   client.on_reconnect { called = true; EM.stop }
      #   client.immediate_reconnect
      # end
      #
      # called.should be_true
    end
  end

  describe '#on_max_reconnects' do
    before do
      Mockingbird.setup(test_options) do
        status 200, "Success"

        on_connection(1) do
          disconnect!
        end

        on_connection(2) do
          disconnect!
        end

        on_connection('*') do
          close
        end
      end
    end

    after { Mockingbird.teardown }

    it "should notify after reconnect limit is reached" do
      pending
      # timeout, retries = nil, nil
      #
      # EM.run do
      #   client = EM::Twitter::Client.new(default_options.merge(:reconnect_options => { :max_reconnects => 1 }))
      #   client.on_max_reconnects do |t, r|
      #     timeout, retries = t, r
      #     EM.stop
      #   end
      #   client.connect
      # end
      #
      # timeout.should eq(EM::ReconnectableConnection::DEFAULT_RECONNECT_OPTIONS[:application_failure][:start])
      # retries.should eq(1)
    end
  end

  describe '#immediate_reconnect' do
    pending
    # it 'closes the connection' do
    #   reconnectable.should_receive(:close_connection).once
    #   reconnectable.immediate_reconnect
    # end
    #
    # it 'does not gracefully close' do
    #   reconnectable.immediate_reconnect
    #   reconnectable.should_not be_gracefully_closed
    # end
    #
    # it 'flags the connection for immediate reconnection' do
    #   reconnectable.immediate_reconnect
    #   reconnectable.should be_immediate_reconnect
    # end
  end

  context 'application failure' do
  end

  context 'network failure' do
    before do
      Mockingbird.setup(test_options) do
        status 0, "Network Failure"

        on_connection(1) do
          disconnect!
        end

        on_connection(2) do
          disconnect!
        end

        on_connection('*') do
          close
        end
      end
    end

    after { Mockingbird.teardown }

    it "should notify after reconnect limit is reached" do
      pending
      # timeout, retries = nil, nil
      #
      #
      #       EM.run do
      #         client = EM::Twitter::Client.new(default_options.merge(:reconnect_options => { :max_reconnects => 1 }))
      #         client.on_max_reconnects do |t, r|
      #           timeout, retries = t, r
      #           EM.stop
      #         end
      #         client.connect
      #       end
      #
      #       timeout.should eq(EM::ReconnectableConnection::DEFAULT_RECONNECT_OPTIONS[:application_failure][:start])
      #       retries.should eq(1)
    end
  end

end