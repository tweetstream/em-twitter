require 'eventmachine'
require 'em/buftok'
require 'uri'
require 'http/parser'
require 'openssl'

require 'em-twitter/proxy'
require 'em-twitter/request'
require 'em-twitter/response'
require 'em-twitter/decoders/base_decoder'
require 'em-twitter/decoders/gzip_decoder'

require 'em-twitter/reconnectors/application_failure'
require 'em-twitter/reconnectors/network_failure'

module EventMachine
  module Twitter
    class Connection < EM::Connection

      MAX_LINE_LENGTH = 1024*1024

      attr_reader :host, :port, :client, :options, :headers
      attr_accessor :reconnector

      def initialize(client, host, port)
        @client             = client
        @host               = host
        @port               = port
        @options            = @client.options
        @on_inited_callback = @options.delete(:on_inited)
        @request            = Request.new(@options)

        if verify_peer?
          @certificate_store  = OpenSSL::X509::Store.new
          @certificate_store.add_file(@options[:ssl][:cert_chain_file])
        end
      end

      # Called after the connection to the server is completed. Initiates a
      #
      def connection_completed
        start_tls(@options[:ssl]) if ssl?
        send_data(@request)
      end

      def post_init
        reset
        invoke_callback(@on_inited_callback)
      end

      # Resets the internals of the connection on initial connection and
      # on reconnection.  Clears the response buffer and resets the reconnector
      def reset
        @buffer               = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
        @parser               = Http::Parser.new(self)
        @last_response        = Response.new
        @response_code        = 0
        @headers              = {}

        @gracefully_closed    = false
        @immediate_reconnect  = false

        @reconnector          = EM::Twitter::Reconnectors::NetworkFailure.new

        set_comm_inactivity_timeout(@options[:timeout]) if @options[:timeout] > 0
      end

      # Receives responses from the server and passes them on to the HttpParser
      def receive_data(data)
        @parser << data
      end

      # Close the connection gracefully, without reconnecting
      def stop
        @gracefully_closed = true
        close_connection
      end

      # Immediately reconnects the connection
      def immediate_reconnect
        @immediate_reconnect = true
        @gracefully_closed = false
        close_connection
      end

      # Called when a connection is disconnected
      def unbind
        schedule_reconnect if @options[:auto_reconnect] && !gracefully_closed?
        invoke_callback(@client.close_callback)
      end

      # Returns a status of the connection, if no response was ever received from
      # the server, then we assume a network failure.
      def network_failure?
        @response_code == 0
      end

      # Returns the current state of the gracefully_closed flag
      # gracefully_closed is set to true when the connection is
      # explicitly stopped using the stop method
      def gracefully_closed?
        @gracefully_closed
      end

      # Returns the current state of the immediate_reconnect flag
      # immediate_reconnect is true when the immediate_reconnect
      # method is invoked on the connection
      def immediate_reconnect?
        @immediate_reconnect
      end

      def update(options={})
        @options.merge!(options)
        immediate_reconnect
      end

      protected

      def handle_stream(data)
        @last_response << @decoder.decode(data)

        if @last_response.complete?
          invoke_callback(@client.each_item_callback, @last_response.body)
        end
      end

      # HttpParser implementation, invoked after response headers are received
      def on_headers_complete(headers)
        @response_code  = @parser.status_code
        @headers        = headers

        @decoder = BaseDecoder.new

        # TODO: Complete gzip support
        # detect gzip encoding and use a decoder for response bodies
        # gzip needs to be detected with the Content-Encoding header
        # @decoder = if gzip?
        #   GzipDecoder.new
        # else
        #   BaseDecoder.new
        # end

        # since we got a response use the application failure reconnector
        # to handle redirects
        @reconnector = EM::Twitter::Reconnectors::ApplicationFailure.new

        # everything below here is error handling so return if we got a 200
        return if @response_code == 200

        case @response_code
        when 401 then invoke_callback(@client.unauthorized_callback)
        when 403 then invoke_callback(@client.forbidden_callback)
        when 404 then invoke_callback(@client.not_found_callback)
        when 406 then invoke_callback(@client.not_acceptable_callback)
        when 413 then invoke_callback(@client.too_long_callback)
        when 416 then invoke_callback(@client.range_unacceptable_callback)
        when 420 then invoke_callback(@client.enhance_your_calm_callback)
        else
          msg = "Unhandled status code: #{@response_code}."
          invoke_callback(@client.error_callback, msg)
        end
      end

      # HttpParser implementation, invoked when a body is received
      def on_body(data)
        begin
          @buffer.extract(data).each do |line|
            handle_stream(line)
          end
          @last_response.reset if @last_response.complete?
        rescue => e
          msg = "#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t")
          invoke_callback(@client.error_callback, msg)

          close_connection
          return
        end
      end

      # It's important that we try to not add a certificate to the store that's
      # already in the store, because OpenSSL::X509::Store will raise an exception.
      def ssl_verify_peer(cert_string)
        cert = nil
        begin
          cert = OpenSSL::X509::Certificate.new(cert_string)
        rescue OpenSSL::X509::CertificateError
          return false
        end

        @last_seen_cert = cert

        if @certificate_store.verify(@last_seen_cert)
          begin
            @certificate_store.add_cert(@last_seen_cert)
          rescue OpenSSL::X509::StoreError => e
            raise e unless e.message == 'cert already in hash table'
          end
          true
        else
          raise OpenSSL::OpenSSLError.new("unable to verify the server certificate of #{@client.host}")
          false
        end
      end

      def ssl_handshake_completed
        unless OpenSSL::SSL.verify_certificate_identity(@last_seen_cert, @client.host)
          fail OpenSSL::OpenSSLError.new("the hostname '#{@client.host}' does not match the server certificate")
          false
        else
          true
        end
      end

      def ssl?
        @options[:ssl]
      end

      def gzip?
        @headers['Content-Encoding'] && @headers['Content-Encoding'] == 'gzip'
      end

      def verify_peer?
        ssl? && @options[:ssl][:verify_peer]
      end

      # Handles reconnection to the server when a disconnect occurs. By using a
      # reconnector, it will gradually increase the time between reconnects
      # per Twitter's reconnection guidelines.
      def schedule_reconnect
        if gracefully_closed?
          reconnect_after(0)
          @gracefully_closed = false
          return
        end

        begin
          @reconnector.increment do |timeout|
            reconnect_after(timeout)
          end
        rescue ReconnectLimitError => e
          invoke_callback(@client.max_reconnects_callback,
                          @reconnector.reconnect_timer,
                          @reconnector.reconnect_count)
        end
      end

      # Performs the reconnection after x seconds have passed.
      # Reconnection is performed immediately if the argument passed
      # is zero.
      #
      # Otherwise it will create an EM::Timer that will reconnect
      def reconnect_after(reconnect_timer)
        invoke_callback(@client.reconnect_callback,
                        @reconnector.reconnect_timer,
                        @reconnector.reconnect_count)

        if reconnect_timer.zero?
          reconnect(@host, @port)
        else
          EM::Timer.new(reconnect_timer) { reconnect(@host, @port) }
        end
      end

      # A utility method used to invoke callback methods against the Client
      def invoke_callback(callback, *args)
        callback.call(*args) if callback
      end

    end
  end
end