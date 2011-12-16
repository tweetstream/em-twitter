module EventMachine
  class Twitter
    class Client

      # A convenience method for creating and connecting.
      def self.connect(options = {})
        new(options).tap do |client|
          client.connect
        end
      end

      def initialize(options = {})
      end

      def initialize(options = {})
        @connection = nil
      end

      def connect
        @connection = EM.connect(gateway, port, Connection, self)
      end

      def each_item &block
        @each_item_callback = block
      end

      def on_error &block
        @error_callback = block
      end

      def on_reconnect &block
        @reconnect_callback = block
      end

      def on_max_reconnects &block
        @max_reconnects_callback = block
      end

      def on_close &block
        @close_callback = block
      end

    end
  end
end