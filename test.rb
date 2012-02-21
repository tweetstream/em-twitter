require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'you,Obama,eli,bachelor,Romney'
    },
    :ssl => {
      :verify_peer      => true,
      :cert_chain_file  => '/etc/ssl/certs/cacert.pem'
    },
    :oauth  => {
      :consumer_key     => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret  => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token            => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret     => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    }
    # , :encoding => 'gzip'
  }

  client = EM::Twitter::Client.connect(options)

  client.each do |item|
    # puts item
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

  EM.add_timer(25) do
    EM.stop
  end

end