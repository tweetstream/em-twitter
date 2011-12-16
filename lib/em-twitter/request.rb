require 'eventmachine'
require 'em/buftok'
require 'uri'
require 'simple_oauth'
require 'http/parser'
# require 'em-twitter/reconnectable_connection'

module EventMachine
  module Twitter
    class Request

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)
      end

      def request_data
        data = []
        request_uri = @options[:path]

        if @proxy
          # proxies need the request to be for the full url
          request_uri = "#{uri_base}:#{@options[:port]}#{request_uri}"
        end

        # unless (q = query).empty?
        #   if @options[:method].to_s.upcase == 'GET'
        #     request_uri << "?#{q}"
        #   else
        #     content = q
        #   end
        # end
        content = '123'

        data << "#{@options[:method]} #{request_uri} HTTP/1.1"
        data << "Host: #{@options[:host]}"
        data << 'Accept: */*'
        data << "User-Agent: #{@options[:user_agent]}" if @options[:user_agent]

        # if @options[:auth]
        #   data << "Authorization: Basic #{[@options[:auth]].pack('m').delete("\r\n")}"
        # elsif @options[:oauth]
        #   data << "Authorization: #{oauth_header}"
        # end

        # if @proxy && @proxy.user
        #   data << "Proxy-Authorization: Basic " + ["#{@proxy.user}:#{@proxy.password}"].pack('m').delete("\r\n")
        # end
        if @options[:method] == 'POST'
          data << "Content-type: #{@options[:content_type]}"
          data << "Content-length: #{content.length}"
        end

        if @options[:headers]
          @options[:headers].each do |name,value|
              data << "#{name}: #{value}"
          end
        end

        data << "\r\n"
      end

      def join(str)
        request_data.join(str)
      end

      def send_request
        request = Request.new(@options)

        send_data request.join("\r\n")
      end

    end
  end
end