require 'spec_helper'

describe EM::Twitter::Connection do

  describe "#post_init" do
    it "calls the on_inited callback" do
      called = false

      EM.run_block do
        client = EM::Twitter::Client.connect(default_options.merge(:on_inited => lambda { called = true}))
      end

      expect(called).to be_true
    end

    it "sets the inactivity timeout" do
      expect(EM).to receive(:set_comm_inactivity_timeout)
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options.merge(:timeout => 2))
      end
    end
  end

  describe "streaming" do
    describe "#each with partial responses" do
      before do
        Mockingbird.setup(test_options) do
          status '200', 'Success'

          on_connection('*') do
            100.times do
              send %({"foo":"ba)
              send %(r"}\r\n)
            end
          end

        end
      end

      after { Mockingbird.teardown }

      it "converts response data into complete buffers" do
        count = 0

        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          client.each do |message|
            count += 1
            if count >= 100
              client.stop
              EM.stop
            end
          end

          EM::Timer.new(10) { EM.stop }
        end

        expect(count).to be >= 100
      end
    end

    describe "#each with full responses" do
      before do
        Mockingbird.setup(test_options) do
          status '200', 'Success'

          on_connection('*') do
            100.times do
              send %({"foo":"bar"}\r\n)
            end
          end

        end
      end

      after { Mockingbird.teardown }

      it "emits each complete response chunk" do
        responses = []

        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          client.each do |message|
            responses << message
            EM.stop if responses.size >= 100
          end

          EM::Timer.new(10) { EM.stop }
        end

        expect(responses.size).to be >= 100
        expect(responses.last).to eq('{"foo":"bar"}')
      end
    end

    describe "#each with extra newlines in responses" do
      before do
        Mockingbird.setup(test_options) do
          status '200', 'Success'

          on_connection('*') do
            100.times do
              send %({"foo":"bar"}\r\n\r\n)
            end
          end

        end
      end

      after { Mockingbird.teardown }

      it "emits each complete response chunk" do
        responses = []

        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          client.each do |message|
            responses << message
            EM.stop if responses.size >= 100
          end

          EM::Timer.new(10) { EM.stop }
        end

        expect(responses.size).to be >= 100
        expect(responses.last).to eq('{"foo":"bar"}')
      end
    end

    describe "stall handling" do
      before do
        stub_const("EM::Twitter::Connection::STALL_TIMEOUT", 5)
        stub_const("EM::Twitter::Connection::STALL_TIMER", 1)

        Mockingbird.setup(test_options) do
          wait(10)
        end
      end

      after { Mockingbird.teardown }

      it "invokes a no-data callback when stalled" do
        called = false
        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          allow(client.connection).to receive(:stalled?).and_return(true)
          client.on_no_data_received do
            called = true
            EM.stop
          end
        end

        expect(called).to be_true
      end

      it "closes the connection when stalled to prompt a reconnect" do
        called = false
        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          expect(client.connection).to receive(:close_connection).once
          allow(client.connection).to receive(:stalled?).and_return(true)
          client.on_no_data_received do
            called = true
            EM.stop
          end
        end

        expect(called).to be_true
      end

      it "invokes a no-data callback when stalled without a response" do
        stalled = false
        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          # this is kind of sneaky, using a stub on gracefully_closed?
          # to set a nil response the first time around to mimic a null
          # response object
          allow(client.connection).to receive(:gracefully_closed?) do
            resp = client.connection.instance_variable_get(:@last_response)
            client.connection.instance_variable_set(:@last_response, nil) if resp.timestamp.nil?
            false
          end
          client.on_no_data_received do
            stalled = client.connection.stalled?
            EM.stop
          end
        end

        expect(stalled).to be_true
      end
    end
  end

  describe "#on_close" do
    it "sets a callback that is invoked when the connection closes" do
      called = false

      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.on_close { called = true }
      end

      expect(called).to be_true
    end
  end

  describe "#stop" do
    it "closes the connection" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        expect(client.connection).to receive(:close_connection).once
        client.stop
      end
    end

    it "gracefully closes" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.stop
        expect(client).to be_gracefully_closed
      end
    end

    it "doesn't auto-reconnect" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.stop
        expect(client.connection.auto_reconnect?).to be_false
      end
    end
  end

  describe "#update" do
    before do
      Mockingbird.setup(test_options) do
        100.times do
          send '{"foo":"bar"}'
        end
      end
    end

    after { Mockingbird.teardown }

    it "updates the options hash" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.connection.update(:params => {:track => 'rangers'})
        expect(client.connection.options[:params]).to eq({:track => 'rangers'})
      end
    end

    it "reconnects after updating" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        expect(client.connection).to receive(:immediate_reconnect).once
        client.connection.update(:params => {:track => 'rangers'})
      end
    end

    it "uses the new options when reconnecting" do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        expect(client.connection).to receive(:send_data) do |request|
          expect(request.to_s).to include('track=rangers')
        end
        client.connection.update(:params => {:track => 'rangers'})
      end
    end
  end

  describe "#auto_reconnect?" do
    before do
      Mockingbird.setup(test_options) do
        100.times do
          send '{"foo":"bar"}'
        end
      end
    end

    after { Mockingbird.teardown }

    it "indicates the auto_reconnect setting" do
      EM.run do
        client = EM::Twitter::Client.connect(default_options)
        EM::Timer.new(1) do
          expect(client.auto_reconnect?).to be_true
          EM.stop
        end
      end
    end

    it "indicates the auto_reconnect setting when false" do
      EM.run do
        client = EM::Twitter::Client.connect(default_options.merge(:auto_reconnect => false))
        EM::Timer.new(1) do
          expect(client.auto_reconnect?).to be_false
          EM.stop
        end
      end
    end
  end

end
