# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elastic/stats/version'

Gem::Specification.new do |spec|
  spec.name          = 'elastic-stats'
  spec.version       = Elastic::Stats::VERSION
  spec.authors       = ['Jugrens du Toit']
  spec.email         = ['jrgns@jrgns.net']
  spec.summary    = 'An utility to fetch various statistics from Elasticsearch.'
  spec.homepage      = 'https://github.com/eagerelk/elastic-stats-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'statsample'
  spec.add_runtime_dependency 'elasticsearch'
end
