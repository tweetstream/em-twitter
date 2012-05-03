require 'spec_helper'

include EM::Twitter::Reconnectors

describe EM::Twitter::Reconnectors::NetworkFailure do
  describe 'initialization' do
    it 'initializes the reconnect_timer' do
      reconn = NetworkFailure.new
      reconn.reconnect_timer.should eq(NetworkFailure::START)
    end

    it 'accepts an options hash' do
      reconn = NetworkFailure.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)
    end
  end

  describe 'reconnect_timer' do
    it 'returns the reconnect_timer' do
      reconn = NetworkFailure.new
      reconn.reconnect_timer = 12
      reconn.reconnect_timer.should eq(12)
    end

    it 'returns the maximum timer when greater than the max' do
      reconn = NetworkFailure.new
      reconn.reconnect_timer = NetworkFailure::MAX + 2
      reconn.reconnect_timer.should eq(NetworkFailure::MAX)
    end
  end

  describe '#increment' do
    it 'increments the reconnect_count' do
      reconn = NetworkFailure.new
      reconn.increment
      reconn.reconnect_count.should eq(1)
    end

    it 'increments the reconect_timer' do
      reconn = NetworkFailure.new
      reconn.increment
      reconn.reconnect_timer.should eq(0.5)
    end

    it 'accepts a block' do
      called = false

      reconn = NetworkFailure.new
      reconn.increment do
        called = true
      end

      called.should be_true
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