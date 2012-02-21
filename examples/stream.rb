require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'yankees'
    },
    :oauth  => {
      :consumer_key     => ENV['CONSUMER_KEY'],
      :consumer_secret  => ENV['CONSUMER_SECRET'],
      :token            => ENV['OAUTH_TOKEN'],
      :token_secret     => ENV['OAUTH_TOKEN_SECRET']
    }
  }

  client = EM::Twitter::Client.connect(options)

  client.each do |result|
    puts result
  end

  client.error do |message|
    puts "oops: error: #{message}"
  end

  client.unauthorized do
    puts "oops: unauthorized"
  end

  client.forbidden do
    puts "oops: unauthorized"
  end

  client.not_found do
    puts "oops: not_found"
  end

  client.not_acceptable do
    puts "oops: not_acceptable"
  end

  client.too_long do
    puts "oops: too_long"
  end

  client.range_unacceptable do
    puts "oops: range_unacceptable"
  end

  client.enhance_your_calm do
    puts "oops: enhance_your_calm"
  end

  EM.add_timer(10) do
    EM.stop
  end

end