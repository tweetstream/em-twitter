module EventMachine
  module Twitter
    class Response

      attr_accessor :body

      def initialize
        @body = ''
      end

      def <<(data)
        data.strip!

        return if data.empty?

        if data[0,1] == '{' || data[data.length-1,1] == '}'
          @body << data
        end
      end

      def complete?
        @body[0,1] == '{' && @body[@body.length-1,1] == '}'
      end
    end
  end
end