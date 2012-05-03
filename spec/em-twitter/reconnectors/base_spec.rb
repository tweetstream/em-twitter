require 'spec_helper'

include EM::Twitter::Reconnectors

describe EM::Twitter::Reconnectors::Base do

  describe 'initialization' do
    it 'initializes the reconnect_count' do
      reconn = Base.new
      reconn.reconnect_count.should be_zero
    end

    it 'accepts an options hash' do
      reconn = Base.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)
    end
  end

  describe '#increment' do
    it 'is undefined' do
      reconn = Base.new
      reconn.increment.should be_nil
    end
  end

  describe '#reset' do
    it 'resets the reconnect_count' do
      reconn = Base.new(:reconnect_count => 25)
      reconn.reconnect_count.should eq(25)

      reconn.reset
      reconn.reconnect_count.should be_zero
    end
  end
end