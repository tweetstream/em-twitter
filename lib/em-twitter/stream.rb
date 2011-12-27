require 'eventmachine'
require 'em/buftok'
require 'uri'
require 'http/parser'
require 'em-twitter/request'
require 'em-twitter/response'
require 'eventmachine/reconnectable_connection'

module EventMachine
  module Twitter
    # class Stream < EM::Connection
    class Stream < ReconnectableConnection

      MAX_LINE_LENGTH = 1024*1024

      attr_reader :host, :port, :code, :headers

      def self.connect(options = {})
        options = DEFAULT_CONNECTION_OPTIONS.merge(options)

        host = options[:host]
        port = options[:port]

        if options[:proxy] && options[:proxy][:uri]
          proxy_uri = URI.parse(options[:proxy][:uri])
          host = proxy_uri.host
          port = proxy_uri.port
        end

        connection = EventMachine.connect host, port, self, options
        connection.start_tls(options[:ssl])
        connection
      end

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)
        @on_inited_callback = options.delete(:on_inited)

        @buffer  = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
        @parser  = Http::Parser.new(self)

        super(:on_unbind => method(:on_unbind), :timeout => @options[:timeout])
      end

      def connection_completed
        send_data Request.new(@options)
      end

      def post_init
        set_comm_inactivity_timeout @options[:timeout] if @options[:timeout] > 0
        @on_inited_callback.call if @on_inited_callback
      end

      def on_unbind
        handle_stream(@buffer.flush) unless @buffer.empty?
      end

      def on_headers_complete(headers)
        @code = @parser.status_code
        if @code != '200'
          handle_error("invalid status code: #{@code}.")
        end
        @headers = headers
      end

      def on_body(data)
        begin
          @buffer.extract(data).each do |line|
            handle_stream(line)
          end
          @last_response = nil
        rescue Exception => e
          handle_error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
          close_connection
          return
        end
      end

      def receive_data(data)
        @parser << data
      end

      def handle_error(e)
        @error_callback.call(e) if @error_callback
      end

      def handle_stream(data)
        @last_response = Response.new if @last_response.nil?
        @last_response << data

        @each_item_callback.call(@last_response.body) if @last_response.complete? && @each_item_callback
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