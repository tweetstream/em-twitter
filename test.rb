require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'you,Obama,eli,bachelor,Romney'
    },
    :oauth  => {
      :consumer_key     => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret  => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token            => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret     => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    } #, :encoding => 'gzip'
  }

  stream = EM::Twitter::Client.connect(options)

  stream.each_item do |item|
    puts item
  end

  stream.on_error do |message|
    puts "oops: on_error: #{message}"
  end

  stream.on_unauthorized do
    puts "oops: on_unauthorized"
  end

  stream.on_forbidden do
    puts "oops: on_unauthorized"
  end

  stream.on_not_found do
    puts "oops: on_not_found"
  end

  stream.on_not_acceptable do
    puts "oops: on_not_acceptable"
  end

  stream.on_too_long do
    puts "oops: on_too_long"
  end

  stream.on_range_unacceptable do
    puts "oops: on_range_unacceptable"
  end

  stream.on_enhance_your_calm do
    puts "oops: on_enhance_your_calm"
  end

  EM.add_timer(25) do
    EM.stop
  end

end