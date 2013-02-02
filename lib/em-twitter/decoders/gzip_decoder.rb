require 'zlib'
require 'stringio'

module EventMachine
  module Twitter
    class GzipDecoder

      def decode(str)
        Zlib::GzipReader.new(StringIO.new(str.to_s)).read
      end

    end
  end
end
