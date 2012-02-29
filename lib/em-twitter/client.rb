require 'em-twitter/connection'

module EventMachine
  module Twitter
    class Client

      attr_accessor :options, :host, :port
      attr_accessor :each_item_callback, :error_callback, :unauthorized_callback, :forbidden_callback, :not_found_callback
      attr_accessor :not_acceptable_callback, :too_long_callback, :range_unacceptable_callback, :enhance_your_calm_callback
      attr_accessor :reconnect_callback, :max_reconnects_callback, :close_callback

      # A convenience method for creating and connecting.
      def self.connect(options = {})
        new(options).tap do |client|
          client.connect
        end
      end

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)

        @host = @options[:host]
        @port = @options[:port]

        if @options[:proxy] && @options[:proxy][:uri]
          proxy_uri = URI.parse(@options[:proxy][:uri])
          @host = proxy_uri.host
          @port = proxy_uri.port
        end
        @connection = nil
      end

      def connect
        @connection = EM.connect(@host, @port, Connection, self)
      end

      def immediate_reconnect
        @connection.immediate_reconnect
      end

      def reconnect
        @connection.reconnect(@host, @port)
      end

      def each(&block)
        @each_item_callback = block
      end

      def error(&block)
        @error_callback = block
      end

      def unauthorized(&block)
        @unauthorized_callback = block
      end

      def forbidden(&block)
        @forbidden_callback = block
      end

      def not_found(&block)
        @not_found_callback = block
      end

      def not_acceptable(&block)
        @not_acceptable_callback = block
      end

      def too_long(&block)
        @too_long_callback = block
      end

      def range_unacceptable(&block)
        @range_unacceptable_callback = block
      end

      def enhance_your_calm(&block)
        @enhance_your_calm_callback = block
      end
      alias :rate_limited :enhance_your_calm

      def on_reconnect(&block)
        @reconnect_callback = block
      end

      def on_max_reconnects(&block)
        @max_reconnects_callback = block
      end

      def on_close(&block)
        @close_callback = block
      end

    end
  end
end