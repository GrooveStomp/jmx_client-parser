# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jmx_client/parser/version'

Gem::Specification.new do |gem|
  gem.name          = 'jmx_client-parser'
  gem.version       = JmxClient::Parser::VERSION
  gem.authors       = ['Aaron Oman']
  gem.email         = ['aaron@unbounce.com']
  gem.description   = %q{Utility to parse cmdline-jmxclient output into Ruby hash data.}
  gem.summary       = %q{Utility to parse cmdline-jmxclient output into Ruby hash data.}
  gem.homepage      = 'https://github.com/GrooveStomp/jmx_client-parser'

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
