require 'spec_helper'

include EM::Twitter::Reconnectors

describe EM::Twitter::Reconnectors::ApplicationFailure do
  describe 'initialization' do
    it 'initializes the reconnect_timer' do
      reconn = ApplicationFailure.new
      reconn.reconnect_timer.should eq(ApplicationFailure::START)
    end

    it 'accepts an options hash' do
      reconn = ApplicationFailure.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)
    end
  end

  describe 'reconnect_timer' do
    it 'returns the reconnect_timer' do
      reconn = ApplicationFailure.new
      reconn.reconnect_timer = 12
      reconn.reconnect_timer.should eq(12)
    end
  end

  describe '#increment' do
    it 'increments the reconnect_count' do
      reconn = ApplicationFailure.new
      reconn.increment
      reconn.reconnect_count.should eq(1)
    end

    it 'increments the reconect_timer' do
      reconn = ApplicationFailure.new
      reconn.increment
      reconn.reconnect_timer.should eq(20)
    end

    it 'accepts a block' do
      called = false

      reconn = ApplicationFailure.new
      reconn.increment do
        called = true
      end

      called.should be_true
    end
  end

  describe '#reset' do
    it 'resets the reconnect_count' do
      reconn = ApplicationFailure.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)

      reconn.reset
      reconn.reconnect_count.should be_zero
    end
  end
end