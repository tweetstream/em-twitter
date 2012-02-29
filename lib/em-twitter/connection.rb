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
require 'eventmachine/reconnectable_connection'

module EventMachine
  module Twitter
    class Connection < ReconnectableConnection

      MAX_LINE_LENGTH = 1024*1024

      attr_reader :host, :port, :headers

      def initialize(client)
        @client             = client
        @options            = @client.options
        @on_inited_callback = @options.delete(:on_inited)
        @request            = Request.new(@options)
        if verify_peer?
          @certificate_store  = OpenSSL::X509::Store.new
          @certificate_store.add_file(@options[:ssl][:cert_chain_file])
        end

        super(client, :on_unbind => method(:on_unbind), :timeout => @options[:timeout])
      end

      def connection_completed
        start_tls(@options[:ssl]) if ssl?
        send_data(@request)
        reset_timeouts
      end

      def post_init
        @buffer             = BufferedTokenizer.new("\r", MAX_LINE_LENGTH)
        @parser             = Http::Parser.new(self)
        @last_response      = Response.new
        @response_code      = 0
        @headers            = {}

        set_comm_inactivity_timeout(@options[:timeout]) if @options[:timeout] > 0
        @on_inited_callback.call if @on_inited_callback
      end

      def receive_data(data)
        @parser << data
      end

      protected

      def handle_error(error)
        @client.error_callback.call(error) if @client.error_callback
      end

      def handle_stream(data)
        @last_response << @decoder.decode(data)

        @client.each_item_callback.call(@last_response.body) if @last_response.complete? && @client.each_item_callback
      end

      def on_unbind
        @client.close_callback.call if @client.close_callback
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
          handle_error("invalid status code: #{@response_code}.")
        end
        EM.stop
      end

      def on_body(data)
        begin
          @buffer.extract(data).each do |line|
            handle_stream(line)
          end
          @last_response.reset if @last_response.complete?
        rescue Exception => e
          handle_error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
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

      def network_failure?
        @response_code == 0
      end

    end
  end
end