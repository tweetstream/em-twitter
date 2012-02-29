require 'spec_helper'

describe EM::ReconnectableConnection do
  let(:reconnectable) do
    conn = EM::ReconnectableConnection.new(EM::Twitter::Client.new, {})
    conn.stub(:close_connection).and_return(true)
    conn
  end

  describe '#stop' do
    it 'closes the connection' do
      reconnectable.should_receive(:close_connection).once
      reconnectable.stop
    end

    it 'gracefully closes' do
      reconnectable.stop
      reconnectable.should be_gracefully_closed
    end
  end

  describe '#immediate_reconnect' do
    it 'closes the connection' do
      reconnectable.should_receive(:close_connection).once
      reconnectable.immediate_reconnect
    end

    it 'does not gracefully close' do
      reconnectable.immediate_reconnect
      reconnectable.should_not be_gracefully_closed
    end

    it 'flags the connection for immediate reconnection' do
      reconnectable.immediate_reconnect
      reconnectable.should be_immediate_reconnect
    end
  end
end