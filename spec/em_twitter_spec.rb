require 'spec_helper'

describe EM::Twitter do
  before do
    EM::Twitter.logger = nil
  end

  describe ".logger" do
    it "returns a Logger by default" do
      expect(EM::Twitter.logger).to be_kind_of(Logger)
    end
  end

  describe ".logger=" do
    it "assigns a custom logger" do
      FakeLogger = Class.new
      EM::Twitter.logger = FakeLogger.new
      expect(EM::Twitter.logger).to be_kind_of(FakeLogger)
    end
  end

end
