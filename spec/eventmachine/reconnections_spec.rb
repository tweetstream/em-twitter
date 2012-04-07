require 'spec_helper'

describe 'EventMachine::ReconnectableConnection' do
  describe 'reconnections' do
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
        timeout, retries = nil, nil

        EM.run do
          client = EM::Twitter::Client.new(default_options.merge(:reconnect_options => { :max_reconnects => 1 }))
          client.on_max_reconnects do |t, r|
            timeout, retries = t, r
            EM.stop
          end
          client.connect
        end

        timeout.should eq(EM::ReconnectableConnection::DEFAULT_RECONNECT_OPTIONS[:application_failure][:start])
        retries.should eq(1)
      end
    end
  end
end