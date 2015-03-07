# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eager/stats/version'

Gem::Specification.new do |spec|
  spec.name          = "eager-stats"
  spec.version       = Eager::Stats::VERSION
  spec.authors       = ["Jugrens du Toit"]
  spec.email         = ["jrgns@jrgns.net"]
  spec.summary       = %q{An utility to fetch various statistics from Elasticsearch.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/eagerelk/eager-stats-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'webmock'
  #spec.add_development_dependency "prettyprint"
  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'statsample'
  spec.add_runtime_dependency 'elasticsearch'
  # spec.add_runtime_dependency "chronic"
end
