# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/rpc/version'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-rpc"
  spec.version       = Sinatra::RPC::VERSION
  spec.authors       = ["Andrea Bernardo Ciddio"]
  spec.email         = ["bcandrea@gmail.com"]
  spec.description   = %q{A Sinatra extension module providing RPC server functionality}
  spec.summary       = %q{The Sinatra::RPC module provides an extension that can be used to build RPC endpoints.}
  spec.homepage      = "https://github.com/bcandrea/sinatra-rpc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "method_source", "~> 0.8.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "sinatra"
end
