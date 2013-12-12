# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'em-twitter/version'

Gem::Specification.new do |spec|
  spec.name        = 'em-twitter'
  spec.version     = EventMachine::Twitter::VERSION
  spec.homepage    = 'https://github.com/spagalloco/em-twitter'
  spec.licenses    = ['MIT']

  spec.authors     = ["Steve Agalloco"]
  spec.email       = ['steve.agalloco@gmail.com']
  spec.description = %q{Twitter Streaming API client for EventMachine}
  spec.summary     = spec.description

  spec.add_dependency 'eventmachine', '~> 1.0'
  spec.add_dependency 'http_parser.rb', '~> 0.6'
  spec.add_dependency 'simple_oauth', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 1.0'

  spec.files = %w(.yardopts CONTRIBUTING.md LICENSE.md README.md Rakefile em-twitter.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")

  spec.require_paths = ['lib']
end
