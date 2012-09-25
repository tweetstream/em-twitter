require 'em-twitter/connection'

module EventMachine
  module Twitter
    class Client

      CALLBACKS = [
        :each_item_callback,
        :error_callback,
        :unauthorized_callback,
        :forbidden_callback,
        :not_found_callback,
        :not_acceptable_callback,
        :too_long_callback,
        :range_unacceptable_callback,
        :enhance_your_calm_callback,
        :reconnect_callback,
        :max_reconnects_callback,
        :close_callback,
        :no_data_callback,
        :service_unavailable_callback
      ].freeze unless defined?(CALLBACKS)

      attr_accessor :connection, :options, :host, :port
      attr_accessor *CALLBACKS

      # A convenience method for creating and connecting.
      def self.connect(options = {})
        new(options).tap do |client|
          client.connect
        end
      end

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)

        validate_client

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
        @connection = EM.connect(@host, @port, Connection, self, @host, @port)
      end

      def each(&block)
        @each_item_callback = block
      end

      def on_error(&block)
        @error_callback = block
      end

      def on_unauthorized(&block)
        @unauthorized_callback = block
      end

      def on_forbidden(&block)
        @forbidden_callback = block
      end

      def on_not_found(&block)
        @not_found_callback = block
      end

      def on_not_acceptable(&block)
        @not_acceptable_callback = block
      end

      def on_too_long(&block)
        @too_long_callback = block
      end

      def on_range_unacceptable(&block)
        @range_unacceptable_callback = block
      end

      def on_enhance_your_calm(&block)
        @enhance_your_calm_callback = block
      end
      alias :on_rate_limited :on_enhance_your_calm

      def on_service_unavailable(&block)
        @service_unavailable_callback = block
      end

      def on_reconnect(&block)
        @reconnect_callback = block
      end

      def on_max_reconnects(&block)
        @max_reconnects_callback = block
      end

      def on_close(&block)
        @close_callback = block
      end

      def on_no_data_received(&block)
        @no_data_callback = block
      end

      # Delegate to EM::Twitter::Connection
      def method_missing(method, *args, &block)
        return super unless @connection.respond_to?(method)
        @connection.send(method, *args, &block)
      end

      def respond_to?(method, include_private=false)
        @connection.respond_to?(method, include_private) || super(method, include_private)
      end

      private

      def validate_client
        if @options[:oauth] && @options[:basic]
          raise ConfigurationError.new('Client cannot be configured for both OAuth and Basic Auth') if !@options[:oauth].empty? && !@options[:basic].empty?
        end
      end

    end
  end
end
