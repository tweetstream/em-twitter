require 'em-twitter/stream'
require 'logger'

module EventMachine
  module Twitter
    DEFAULT_CONNECTION_OPTIONS = {
      :host           => 'stream.twitter.com',
      :port           => 443,
      :method         => 'POST',
      :content_type   => "application/x-www-form-urlencoded",
      :path           => '/1/statuses/filter.json',
      :params         => {},
      :headers        => {}
    }

        #
        #   :ssl            => false,
        #   :user_agent     => 'TwitterStream',
        #   :timeout        => 0,
        #   :proxy          => ENV['HTTP_PROXY'],
        #   :auth           => nil,
        #   :auto_reconnect => true
        # }

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end
  end
end
