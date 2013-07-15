require 'spec_helper'

include EM::Twitter

describe "EM::Twitter::Connection reconnections" do

  describe "reconnector setting" do
    context "on connect" do
      before do
        Mockingbird.setup(test_options) do
          status 200, 'Success'
        end
      end

      after { Mockingbird.teardown }

      it "uses the network failure reconnector" do
        EM.run_block do
          client = Client.connect(default_options)
          expect(client.connection.reconnector).to be_kind_of(Reconnectors::NetworkFailure)
        end
      end
    end

    context "after successful connect" do
      before do
        Mockingbird.setup(test_options) do
          status 200, 'Success'
        end
      end

      after { Mockingbird.teardown }

      it "resets the network failure reconnector" do
        expect_any_instance_of(Reconnectors::NetworkFailure).to receive(:reset)
        EM.run do
          EM::Timer.new(1) { EM.stop }
          client = Client.connect(default_options)
        end
      end

      it "resets the application failure reconnector" do
        expect_any_instance_of(Reconnectors::ApplicationFailure).to receive(:reset)
        EM.run do
          EM::Timer.new(1) { EM.stop }
          client = Client.connect(default_options)
          # EM::Timer.new(1) { EM.stop }
        end
      end
    end

    context "on 4xx responses" do
      before do
        Mockingbird.setup(test_options) do
          status 401, 'Unauthorized'
        end
      end

      after { Mockingbird.teardown }

      it "uses the application failure reconnector" do
        EM.run do
          client = Client.connect(default_options)
          EM::Timer.new(1) do
            expect(client.connection.reconnector).to be_kind_of(Reconnectors::ApplicationFailure)
            EM.stop
          end
        end
      end
    end

    context "on reconnects" do
      before do
        Mockingbird.setup(test_options) do
          on_connection(1) do
            status 401, 'Unauthorized'
            disconnect!
          end

          wait(5)
        end
      end

      after { Mockingbird.teardown }

      it "set the reconnector to the network failure reconnector" do
        EM.run do
          client = Client.connect(default_options)
          EM::Timer.new(1) do
            expect(client.connection.reconnector).to be_kind_of(Reconnectors::NetworkFailure)
            EM.stop
          end
        end
      end
    end
  end

  describe "#reconnect" do
    before do
      Mockingbird.setup(test_options) do
        on_connection(1) do
          disconnect!
        end
      end
    end

    after { Mockingbird.teardown }

    it "calls the on_reconnect callback on reconnects" do
      called = false

      EM.run do
        client = Client.connect(default_options)
        client.on_reconnect { called = true; EM.stop }
      end

      expect(called).to be_true
    end

    it "does not reconnect when auto_reconnect is false" do
      EM.run do
        client = Client.connect(default_options.merge(:auto_reconnect => false))
        expect(client).not_to receive(:reconnect)
        client.on_close { EM.stop }
      end
    end
  end

  describe "#immediate_reconnect" do
    before do
      Mockingbird.setup(test_options) do
        100.times do
          send '{"foo":"bar"}'
        end
      end
    end

    after { Mockingbird.teardown }

    it "reconnects immediately" do
      called = false

      EM.run_block do
        client = Client.connect(default_options)
        client.on_reconnect { called = true; EM.stop }
        client.immediate_reconnect
      end

      expect(called).to be_true
    end

    it "reconnects the current connection" do
      EM.run_block do
        client = Client.connect(default_options)
        expect(client.connection).to receive(:reconnect).once
        client.reconnect
      end
    end
  end

  describe "#on_max_reconnects" do
    context "application failure" do
      before do
        Mockingbird.setup(test_options) do
          status 200, "Success"

          on_connection('*') do
            disconnect!
          end
        end
      end

      after { Mockingbird.teardown }

      it "notifies after reconnect limit is reached" do
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

        expect(timeout).to eq(10)
        expect(retries).to eq(320)
      end
    end

    context "network failure" do
      before do
        Mockingbird.setup(test_options) do
          status 200, "Success"

          on_connection('*') do
            disconnect!
          end
        end
      end

      after { Mockingbird.teardown }

      it "notifies after reconnect limit is reached" do
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

        expect(timeout).to eq(0.25)
        expect(retries).to eq(320)
      end
    end
  end
end
