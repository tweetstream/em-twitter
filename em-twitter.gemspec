# encoding: utf-8
require File.expand_path('../lib/em-twitter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'em-twitter'
  gem.version     = EventMachine::Twitter::VERSION
  gem.homepage    = 'https://github.com/spagalloco/em-twitter'

  gem.author      = "Steve Agalloco"
  gem.email       = 'steve.agalloco@gmail.com'
  gem.description = %q{Twitter Streaming API client for EventMachine}
  gem.summary     = %q{Twitter Streaming API client for EventMachine}

  gem.add_dependency "eventmachine", ">= 1.0.0.beta.4"
  gem.add_dependency "http_parser.rb", "~> 0.5"
  gem.add_dependency "simple_oauth", "~> 0.1"

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdiscount'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'mockingbird', "~> 0.1.1"
  gem.add_development_dependency 'guard-rspec'

  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ['lib']
end
