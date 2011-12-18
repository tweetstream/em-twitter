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

      MAX_LINE_LENGTH = 1024*1024

      attr_accessor :host, :port

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
        connection.start_tls
        connection
      end

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)
        # EM::Twitter.logger.info(@options.inspect)

        @buffer  = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
        @parser  = Http::Parser.new(self)
      end

      def connection_completed
        send_request
      end

      # Called when the status line and all headers have been read from the
      # stream.
      def on_headers_complete(headers)
        # EM::Twitter.logger.info(headers)
        if @parser.status_code.to_i != 200
          EM::Twitter.logger.info("invalid status code: #{@parser.status_code}.")
          # receive_error("invalid status code: #{@code}.")
        end
        # self.headers = headers
      end

      # Called every time a chunk of data is read from the connection once it has
      # been opened and after the headers have been processed.
      def on_body(data)
        begin
          # EM::Twitter.logger.info(data)
          @buffer.extract(data).each do |line|
            # EM::Twitter.logger.info(line)
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
        @parser << data
      end

      def send_request
        puts Request.new(@options).to_s
        send_data Request.new(@options).to_s
        EM::Twitter.logger.info('request sent!')
      end

    end
  end
end