require 'bundler/setup'
require 'em-twitter'

EM::run do

  EM::Twitter::Stream.connect

  EM.add_timer(10) do
    EM.stop
  end

end