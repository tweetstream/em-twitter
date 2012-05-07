require 'spec_helper'

include EM::Twitter

describe 'EM::Twitter::Connection reconnections' do

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
      called = false

      EM.run do
        client = Client.connect(default_options)
        client.on_reconnect { called = true; EM.stop }
      end

      called.should be_true
    end

    it 'does not reconnect when auto_reconnect is false' do
      EM.run do
        client = Client.connect(default_options.merge(:auto_reconnect => false))
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
      called = false

      EM.run_block do
        client = Client.connect(default_options)
        client.on_reconnect { called = true; EM.stop }
        client.immediate_reconnect
      end

      called.should be_true
    end

    it 'reconnects the current connection' do
      EM.run_block do
        client = Client.connect(default_options)
        client.connection.should_receive(:reconnect).once
        client.reconnect
      end
    end
  end

  describe '#on_max_reconnects' do
    context 'application failure' do
      before do
        Mockingbird.setup(test_options) do
          status 200, "Success"

          on_connection('*') do
            disconnect!
          end
        end
      end

      after { Mockingbird.teardown }

      it "should notify after reconnect limit is reached" do
        timeout, retries = nil, nil

        EM.run do
          client = Client.new(default_options)
          client.on_max_reconnects do |t, r|
            timeout, retries = t, r
            EM.stop
          end
          client.connect

          # do this so that EM doesn't create timers that grind
          # this test to a halt
          client.connection.reconnector = Reconnectors::ApplicationFailure.new(:reconnect_count => 320)
        end

        timeout.should eq(20)
        retries.should eq(321)
      end
    end

    context 'network failure' do
      before do
        Mockingbird.setup(test_options) do
          status 200, "Success"

          on_connection('*') do
            disconnect!
          end
        end
      end

      after { Mockingbird.teardown }

      it "should notify after reconnect limit is reached" do
        timeout, retries = nil, nil

        EM.run do
          client = Client.new(default_options)
          client.on_max_reconnects do |t, r|
            timeout, retries = t, r
            EM.stop
          end
          client.connect

          # do this so that EM doesn't create timers that grind
          # this test to a halt
          client.connection.reconnector = Reconnectors::NetworkFailure.new(:reconnect_count => 320)
        end

        timeout.should eq(0.5)
        retries.should eq(321)
      end
    end
  end
end