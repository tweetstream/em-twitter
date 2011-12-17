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

      def self.connect(options = {})
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

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)
        EM::Twitter.logger.info(@options.inspect)
        @parser  = Http::Parser.new
        @parser.on_headers_complete = method(:handle_headers_complete)
        @parser.on_body = method(:receive_stream_data)
      end

      def connection_completed
        EM::Twitter.logger.info('sending request')
        send_request
      end

      # Called when the status line and all headers have been read from the
      # stream.
      def handle_headers_complete(headers)
        @code = @parser.status_code.to_i
        if @code != 200
          EM::Twitter.logger.info("invalid status code: #{@code}.")
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
            EM::Twitter.logger.info(line)
            # parse_stream_line(line)
          end
          @stream  = ''
        rescue Exception => e
          EM::Twitter.logger.error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
          receive_error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
          close_connection
          return
        end
      end

      # Receives raw data from the HTTP connection and pushes it into the
      # HTTP parser which then drives subsequent callbacks.
      def receive_data(data)
        EM::Twitter.logger.info('got data')
        EM::Twitter.logger.info(data)
        @parser << data
      end

      def send_request
        send_data Request.new(@options).to_s
        EM::Twitter.logger.info('request sent!')
      end

    end
  end
end