require 'spec_helper'

describe EM::Twitter::Connection do

  describe '#post_init' do
    it 'calls the on_inited callback' do
      called = false

      EM.run_block do
        client = EM::Twitter::Client.connect(default_options.merge(:on_inited => lambda { called = true}))
      end

      called.should be_true
    end

    it 'sets the inactivity timeout' do
      EM.should_receive(:set_comm_inactivity_timeout)
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options.merge(:timeout => 2))
      end
    end
  end

  describe 'streaming' do
    describe '#receive_data' do
      before do
        Mockingbird.setup(test_options) do
          100.times do
            send '{"foo":"ba'
            send 'r"}'
          end
        end
      end

      after { Mockingbird.teardown }

      it 'converts response data into complete buffers' do
        count = 0

        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          client.each do |message|
            count = count + 1
            EM.stop if count == 100
          end
        end

        count.should == 100
      end
    end

    describe '#each' do
      before do
        Mockingbird.setup(test_options) do
          100.times do
            send '{"foo":"bar"}'
          end
        end
      end

      after { Mockingbird.teardown }

      it 'emits each complete response chunk' do
        count = 0

        EM.run do
          client = EM::Twitter::Client.connect(default_options)
          client.each do |message|
            count = count + 1
            EM.stop if count == 100
          end
        end

        count.should == 100
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

      called.should be_true
    end
  end

  describe '#stop' do
    it 'closes the connection' do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.connection.should_receive(:close_connection).once
        client.stop
      end
    end

    it 'gracefully closes' do
      EM.run_block do
        client = EM::Twitter::Client.connect(default_options)
        client.stop
        client.should be_gracefully_closed
      end
    end
  end

end