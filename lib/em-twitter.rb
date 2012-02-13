require 'em-twitter/stream'
require 'em-twitter/version'
require 'logger'

module EventMachine
  module Twitter
    DEFAULT_CONNECTION_OPTIONS = {
      :host           => 'stream.twitter.com',
      :port           => 443,
      :method         => 'POST',
      :content_type   => "application/x-www-form-urlencoded",
      :path           => '/',
      :params         => {},
      :headers        => {},
      :user_agent     => "EM::Twitter Ruby Gem #{EM::Twitter::VERSION}",
      :proxy          => nil,
      :ssl            => {},
      :timeout        => 0,
      :auth           => {},
      :encoding       => nil
    }

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end
  end
end
