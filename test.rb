require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :params => { :track => 'yankees' },
    :oauth  => {
      :consumer_key => 'cVcIw5zoLFE2a4BdDsmmA',
      :consumer_secret => 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA',
      :token => '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I',
      :token_secret => 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
    }
  }

  EM::Twitter::Stream.connect(options)

  EM.add_timer(10) do
    EM.stop
  end

end