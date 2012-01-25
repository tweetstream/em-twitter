require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :path   => '/1/statuses/filter.json',
    :params => {
      :track            => 'Obama,SOTU'
    },
    :oauth  => {
      :consumer_key     => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret  => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token            => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret     => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    }
  }

  stream = EM::Twitter::Stream.connect(options)

  stream.each_item do |item|
    puts item
  end

  stream.on_error do |message|
    puts "oops: #{message}"
  end

  stream.on_unauthorized do |message|
    puts "oops: #{message}"
  end

  stream.on_forbidden do |message|
    puts "oops: #{message}"
  end

  stream.on_not_found do |message|
    puts "oops: #{message}"
  end

  stream.on_not_acceptable do |message|
    puts "oops: #{message}"
  end

  stream.on_too_long do |message|
    puts "oops: #{message}"
  end

  stream.on_range_unacceptable do |message|
    puts "oops: #{message}"
  end

  stream.on_enhance_your_calm do |message|
    puts "oops: #{message}"
  end

  EM.add_timer(15) do
    EM.stop
  end

end