require 'spec_helper'

describe EM::ReconnectableConnection do
  describe '#stop' do
    it 'closes the connection' do
      reconnectable = EM::ReconnectableConnection.new(EM::Twitter::Client.new, {})
      reconnectable.should_receive(:close_connection).once
      reconnectable.stop
    end
  end

  describe '#immediate_reconnect' do
    pending
  end

end