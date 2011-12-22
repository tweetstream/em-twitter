require 'uri'
require 'simple_oauth'

module EventMachine
  module Twitter
    class Request

      def initialize(options = {})
        @options = DEFAULT_CONNECTION_OPTIONS.merge(options)
        @proxy = @options.delete(:proxy)
      end

      def to_s
        content = query

        data = []
        data << "#{@options[:method]} #{request_uri} HTTP/1.1"
        data << "Host: #{@options[:host]}"
        data << 'Accept: */*'
        data << "User-Agent: #{@options[:user_agent]}" if @options[:user_agent]
        data << "Content-type: #{@options[:content_type]}"
        data << "Content-length: #{content.length}"
        data << "Authorization: #{oauth_header}"
        data << "Proxy-Authorization: Basic #{proxy_header}" if proxy?

        if @options[:headers]
          @options[:headers].each do |name, value|
              data << "#{name}: #{value}"
          end
        end

        data << "\r\n"
        data = data.join("\r\n")
        data << content
        data
      end

      def proxy?
        @proxy
      end

      private
      def proxy_header
        ["#{@proxy[:user]}:#{@proxy[:password]}"].pack('m').delete("\r\n") if @proxy[:user] && @proxy[:password]
      end

      def params
        flat = {}
        @options[:params].each do |param, val|
          next if val.to_s.empty? || (val.respond_to?(:empty?) && val.empty?)
          val = val.join(",") if val.respond_to?(:join)
          flat[param.to_s] = val.to_s
        end
        flat
      end

      def query
        params.map do |param, value|
          [param, SimpleOAuth::Header.encode(value)].join("=")
        end.sort.join("&")
      end

      def oauth_header
        SimpleOAuth::Header.new(@options[:method], full_uri, params, @options[:oauth])
      end

      def proxy_uri
        "#{uri_base}:#{@options[:port]}#{@options[:path]}"
      end

      def request_uri
        proxy? ? proxy_uri : @options[:path]
      end

      def uri_base
        "https://#{@options[:host]}"
      end

      def full_uri
        proxy? ? proxy_uri : "#{uri_base}#{request_uri}"
      end
    end
  end
end