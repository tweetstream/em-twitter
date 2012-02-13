require 'spec_helper'

describe EM::Twitter::BaseDecoder do

  describe '#decode' do
    before do
      @decoder = EM::Twitter::BaseDecoder.new
    end

    it 'passes through the response data' do
      @decoder.decode('abc').should eq('abc')
    end
  end

end