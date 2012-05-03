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

require 'em-twitter/reconnectors/base'
require 'em-twitter/reconnectors/application_failure'
require 'em-twitter/reconnectors/network_failure'

module EventMachine
  module Twitter
    class Connection < EM::Connection

      MAX_LINE_LENGTH = 1024*1024

      DEFAULT_RECONNECT_OPTIONS = {
        :network_failure => {
          :start  => 0.25,
          :add    => 0.25,
          :max    => 16
        },
        :application_failure => {
          :start    => 10,
          :multiple => 2
        },
        :auto_reconnect => true,
        :max_reconnects => 320,
        :max_retries    => 10
      }

      attr_reader :host, :port, :headers

      def initialize(client)
        @client             = client
        @options            = @client.options
        @on_inited_callback = @options.delete(:on_inited)
        @request            = Request.new(@options)
        @reconnector        = nil

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
        reset_timeouts
      end

      def post_init
        @buffer               = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
        @parser               = Http::Parser.new(self)
        @last_response        = Response.new
        @response_code        = 0
        @headers              = {}
        @gracefully_closed    = false
        @immediate_reconnect  = false

        @nf_last_reconnect    = nil
        @af_last_reconnect    = nil

        @reconnect_retries    = 0

        set_comm_inactivity_timeout(@options[:timeout]) if @options[:timeout] > 0
        @on_inited_callback.call if @on_inited_callback
      end

      def receive_data(data)
        @parser << data
      end

      def stop
        puts 'closing'
        @gracefully_closed = true
        close_connection
      end

      def immediate_reconnect
        @immediate_reconnect = true
        @gracefully_closed = false
        close_connection
      end

      def unbind
        schedule_reconnect if @options[:auto_reconnect] && !gracefully_closed?
        @client.close_callback.call if @client.close_callback
      end

      #
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

      protected

      def handle_stream(data)
        @last_response << @decoder.decode(data)

        @client.each_item_callback.call(@last_response.body) if @last_response.complete? && @client.each_item_callback
      end

      def on_headers_complete(headers)
        @response_code  = @parser.status_code
        @headers        = headers

        @decoder = if gzip?
          GzipDecoder.new
        else
          BaseDecoder.new
        end

        return if @response_code == 200

        case @response_code
        when 401
          @client.unauthorized_callback.call if @client.unauthorized_callback
        when 403
          @client.forbidden_callback.call if @client.forbidden_callback
        when 404
          @client.not_found_callback.call if @client.not_found_callback
        when 406
          @client.not_acceptable_callback.call if @client.not_acceptable_callback
        when 413
          @client.too_long_callback.call if @client.too_long_callback
        when 416
          @client.range_unacceptable_callback.call if @client.range_unacceptable_callback
        when 420
          @client.enhance_your_calm_callback.call if @client.enhance_your_calm_callback
        else
          msg = "invalid status code: #{@response_code}."
          @client.error_callback.call(msg) if @client.error_callback
        end
      end

      def on_body(data)
        begin
          @buffer.extract(data).each do |line|
            handle_stream(line)
          end
          @last_response.reset if @last_response.complete?
        rescue => e
          msg = "#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t")
          @client.error_callback.call(msg) if @client.error_callback

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

      def schedule_reconnect
        timeout = reconnect_timeout

        @reconnect_retries += 1
        if timeout <= @reconnect_options[:max_reconnects] && @reconnect_retries <= @reconnect_options[:max_retries]
          reconnect_after(timeout)
        else
          @client.max_reconnects_callback.call(timeout, @reconnect_retries) if @client.max_reconnects_callback
        end
      end

      def reconnect_after(timeout)
        @client.reconnect_callback.call(timeout, @reconnect_retries) if @client.reconnect_callback

        if timeout == 0
          @client.reconnect
        else
          EM::Timer.new(timeout) { @client.reconnect }
        end
      end

      def reconnect_timeout
        if immediate_reconnect?
          @immediate_reconnect = false
          return 0
        end

        if network_failure?
          if @nf_last_reconnect
            @nf_last_reconnect += @reconnect_options[:network_failure][:add]
          else
            @nf_last_reconnect = @reconnect_options[:network_failure][:start]
          end
          [@nf_last_reconnect,@reconnect_options[:network_failure][:max]].min
        else
          if @af_last_reconnect
            @af_last_reconnect *= @reconnect_options[:application_failure][:mul]
          else
            @af_last_reconnect = @reconnect_options[:application_failure][:start]
          end
          @af_last_reconnect
        end
      end

      def reset_timeouts
        # @reconnector.reset
        @nf_last_reconnect = @af_last_reconnect = nil
        @reconnect_retries = 0
      end

    end
  end
end