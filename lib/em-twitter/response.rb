module EventMachine
  module Twitter
    class Response

      attr_reader :body

      def initialize(body = '')
        @body = body
      end

      def concat(data)
        return unless data && data.size > 0

        data.strip!

        return if data.empty?

        if json_start?(data) || json_end?(data)
          @body << data
        end
      end
      alias :<< :concat

      def complete?
        json_start?(@body) && json_end?(@body)
      end

      def empty?
        @body == ''
      end

      def reset
        @body = ''
      end

      private
      def json_start?(data)
        data[0,1] == '{'
      end

      def json_end?(data)
        data[data.length-1,1] == '}'
      end
    end
  end
end