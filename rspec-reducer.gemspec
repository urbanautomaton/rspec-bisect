# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/reducer/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-reducer"
  spec.version       = RSpec::Reducer::VERSION
  spec.authors       = ["Simon Coffey"]
  spec.email         = ["simon@urbanautomaton.com"]
  spec.summary       = %q{Reduce order-dependent RSpec test failures}
  spec.description   = %q{Reduces a set of order-dependent failing RSpec tests to a minimal set of example groups}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end