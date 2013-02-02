require 'spec_helper'

describe EM::Twitter::BaseDecoder do

  describe "#decode" do
    before do
      @decoder = EM::Twitter::BaseDecoder.new
    end

    it "passes through the response data" do
      expect(@decoder.decode('abc')).to eq('abc')
    end
  end

end
