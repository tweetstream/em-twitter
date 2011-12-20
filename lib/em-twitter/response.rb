module EventMachine
  module Twitter
    class Response

      attr_reader :body

      def initialize(body = '')
        @body = body
      end

      def concat(data)
        data.strip!

        return if data.empty?

        if data[0,1] == '{' || data[data.length-1,1] == '}'
          @body << data
        end
      end
      alias :<< :concat

      def complete?
        @body[0,1] == '{' && @body[@body.length-1,1] == '}'
      end
    end
  end
end