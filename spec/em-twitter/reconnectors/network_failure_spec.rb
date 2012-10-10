require 'spec_helper'

include EM::Twitter::Reconnectors

describe EM::Twitter::Reconnectors::NetworkFailure do
  describe "initialization" do
    it "initializes the reconnect_timeout" do
      reconn = NetworkFailure.new
      expect(reconn.reconnect_timeout).to eq(NetworkFailure::START)
    end

    it "accepts an options hash" do
      reconn = NetworkFailure.new(:reconnect_count => 25)
      expect(reconn.reconnect_count).to eq(25)
    end
  end

  describe "reconnect_timeout" do
    it "returns the reconnect_timeout" do
      reconn = NetworkFailure.new
      reconn.reconnect_timeout = 12
      expect(reconn.reconnect_timeout).to eq(12)
    end

    it "returns the maximum timeout when greater than the max" do
      reconn = NetworkFailure.new
      reconn.reconnect_timeout = NetworkFailure::MAX_TIMEOUT + 2
      expect(reconn.reconnect_timeout).to eq(NetworkFailure::MAX_TIMEOUT)
    end
  end

  describe "#increment" do
    it "increments the reconnect_count" do
      reconn = NetworkFailure.new
      reconn.increment
      expect(reconn.reconnect_count).to eq(1)
    end

    it "increments the reconnect_timeout" do
      reconn = NetworkFailure.new
      reconn.increment
      expect(reconn.reconnect_timeout).to eq(0.5)
    end

    it "accepts a block and yields the current timeout" do
      recon_timeout = 0

      reconn = NetworkFailure.new
      reconn.increment do |timeout|
        recon_timeout = timeout
      end

      expect(recon_timeout).to eq(0.25)
    end

    it "raises an ReconnectLimitError after exceeding max reconnects" do
      expect {
        reconn = NetworkFailure.new(:reconnect_count => 11)
        reconn.increment
      }.to raise_error(EventMachine::Twitter::ReconnectLimitError)
    end

    it "raises an ReconnectLimitError after exceeding the reconnect time limit" do
      expect {
        reconn = NetworkFailure.new(:reconnect_timeout => 321)
        reconn.increment
      }.to raise_error(EventMachine::Twitter::ReconnectLimitError)
    end
  end

  describe "#reset" do
    it "resets the reconnect_count" do
      reconn = NetworkFailure.new(:reconnect_count => 25)
      expect(reconn.reconnect_count).to eq(25)

      reconn.reset
      expect(reconn.reconnect_count).to be_zero
    end
  end
end
