# encoding: utf-8
require File.expand_path('../lib/em-twitter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'em-twitter'
  gem.version     = EventMachine::Twitter::VERSION
  gem.homepage    = 'https://github.com/spagalloco/em-twitter'

  gem.author      = "Steve Agalloco"
  gem.email       = 'steve.agalloco@gmail.com'
  gem.description = %q{TODO: Write a gem description}
  gem.summary     = %q{TODO: Write a gem summary}

  gem.add_dependency "eventmachine", ">= 1.0.0.beta.3"
  gem.add_dependency "http_parser.rb", "~> 0.5"
  gem.add_dependency "simple_oauth", "~> 0.1"

  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rdiscount', '~> 1.6'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov', '~> 0.5'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.add_development_dependency 'mockingbird', "~> 0.1.1"

  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ['lib']
end
