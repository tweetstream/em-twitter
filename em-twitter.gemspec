# encoding: utf-8
require File.expand_path('../lib/em-twitter/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = 'em-twitter'
  spec.version     = EventMachine::Twitter::VERSION
  spec.homepage    = 'https://github.com/spagalloco/em-twitter'
  spec.licenses    = ['MIT']

  spec.author      = "Steve Agalloco"
  spec.email       = 'steve.agalloco@gmail.com'
  spec.description = %q{Twitter Streaming API client for EventMachine}
  spec.summary     = %q{Twitter Streaming API client for EventMachine}

  spec.add_dependency 'eventmachine', '~> 1.0'
  spec.add_dependency 'http_parser.rb', '~> 0.5'
  spec.add_dependency 'simple_oauth', '~> 0.1'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rdiscount'
  spec.add_development_dependency 'rspec', '>= 2.11'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'mockingbird', '>= 0.2'
  spec.add_development_dependency 'guard-rspec'

  spec.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  spec.files       = `git ls-files`.split("\n")
  spec.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  spec.require_paths = ['lib']
end
