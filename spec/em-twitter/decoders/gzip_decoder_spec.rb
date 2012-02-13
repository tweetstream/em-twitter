require 'spec_helper'

describe EM::Twitter::GzipDecoder do

  describe '#decode' do
    before do
      @decoder = EM::Twitter::GzipDecoder.new
    end

    it 'decodes the response data' do
      output = StringIO.new
      gz = Zlib::GzipWriter.new(output)
      gz.write('abc')
      gz.close

      @decoder.decode(output.string).should eq('abc')
    end
  end

end