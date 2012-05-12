require 'spec_helper'

include EM::Twitter::Reconnectors

describe EM::Twitter::Reconnectors::NetworkFailure do
  describe 'initialization' do
    it 'initializes the reconnect_timeout' do
      reconn = NetworkFailure.new
      reconn.reconnect_timeout.should eq(NetworkFailure::START)
    end

    it 'accepts an options hash' do
      reconn = NetworkFailure.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)
    end
  end

  describe 'reconnect_timeout' do
    it 'returns the reconnect_timeout' do
      reconn = NetworkFailure.new
      reconn.reconnect_timeout = 12
      reconn.reconnect_timeout.should eq(12)
    end

    it 'returns the maximum timeout when greater than the max' do
      reconn = NetworkFailure.new
      reconn.reconnect_timeout = NetworkFailure::MAX + 2
      reconn.reconnect_timeout.should eq(NetworkFailure::MAX)
    end
  end

  describe '#increment' do
    it 'increments the reconnect_count' do
      reconn = NetworkFailure.new
      reconn.increment
      reconn.reconnect_count.should eq(1)
    end

    it 'increments the reconnect_timeout' do
      reconn = NetworkFailure.new
      reconn.increment
      reconn.reconnect_timeout.should eq(0.5)
    end

    it 'accepts a block and yields the current timeout' do
      recon_timeout = 0

      reconn = NetworkFailure.new
      reconn.increment do |timeout|
        recon_timeout = timeout
      end

      recon_timeout.should eq(0.5)
    end

    it 'raises an ReconnectLimitError after exceeding max reconnects' do
      lambda {
        reconn = NetworkFailure.new(:reconnect_count => 11)
        reconn.increment
      }.should raise_error(EventMachine::Twitter::ReconnectLimitError)
    end

    it 'raises an ReconnectLimitError after exceeding the reconnect time limit' do
      lambda {
        reconn = NetworkFailure.new(:reconnect_timeout => 321)
        reconn.increment
      }.should raise_error(EventMachine::Twitter::ReconnectLimitError)
    end
  end

  describe '#reset' do
    it 'resets the reconnect_count' do
      reconn = NetworkFailure.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)

      reconn.reset
      reconn.reconnect_count.should be_zero
    end
  end
end