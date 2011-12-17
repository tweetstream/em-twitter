require 'bundler/setup'
require 'em-twitter'

EM::run do

  options = {
    :params => { :track => 'yankees' },
    :oauth  => {
      :consumer_key => '123',
      :consumer_secret => '4556',
      :token => 'abc',
      :token_secret => 'def'
    }
  }

  EM::Twitter::Stream.connect(options)

  EM.add_timer(10) do
    EM.stop
  end

end