require 'eventmachine'
require 'em/buftok'
require 'uri'
require 'simple_oauth'
require 'http/parser'
require 'em-twitter/request'
# require 'em-twitter/reconnectable_connection'

module EventMachine
  module Twitter
    class Stream < EM::Connection #ReconnectableConnection

      class << self
        def connect(options = {})
          options[:port] = 443 if options[:ssl] && !options.has_key?(:port)
          options = DEFAULT_CONNECTION_OPTIONS.merge(options)

          host = options[:host]
          port = options[:port]

          if options[:proxy]
            proxy_uri = URI.parse(options[:proxy])
            host = proxy_uri.host
            port = proxy_uri.port
          end

          connection = EventMachine.connect host, port, self, options
          connection.start_tls if options[:ssl]
          connection
        end
      end

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)

        @parser  = Http::Parser.new
        @parser.on_headers_complete = method(:handle_headers_complete)
        @parser.on_body = method(:receive_stream_data)
      end

      def connection_completed
        send_request
      end

      # Called when the status line and all headers have been read from the
      # stream.
      def handle_headers_complete(headers)
        @code = @parser.status_code.to_i
        if @code != 200
          puts "invalid status code: #{@code}."
          # receive_error("invalid status code: #{@code}.")
        end
        # self.headers = headers
        # @state = :stream
      end

      # Called every time a chunk of data is read from the connection once it has
      # been opened and after the headers have been processed.
      def receive_stream_data(data)
        begin
          @buffer.extract(data).each do |line|
            puts line
            # parse_stream_line(line)
          end
          @stream  = ''
        rescue Exception => e
          receive_error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
          close_connection
          return
        end
      end

      # Receives raw data from the HTTP connection and pushes it into the
      # HTTP parser which then drives subsequent callbacks.
      def receive_data(data)
        @parser << data
      end

      def send_request
        send_data Request.new(@options).join("\r\n")
      end

    end
  end
end