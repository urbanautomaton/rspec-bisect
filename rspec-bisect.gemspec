# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec-bisect/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-bisect"
  spec.version       = RSpecBisect::VERSION
  spec.authors       = ["Simon Coffey"]
  spec.email         = ["simon@urbanautomaton.com"]
  spec.summary       = %q{Isolate order-dependent RSpec test failures}
  spec.description   = %q{Reduces a set of order-dependent failing RSpec tests to a minimal set of examples}
  spec.homepage      = "https://github.com/urbanautomaton/rspec-bisect"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
