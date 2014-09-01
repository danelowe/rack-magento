# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/magento/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-magento"
  spec.version       = Rack::Magento::VERSION
  spec.authors       = ["Dane Lowe"]
  spec.email         = ["dane@avidonline.co.nz"]
  spec.summary       = %q{Serve Magento from Rack.}
  spec.description   = %q{Quick implementation of rack::legacy/rack::reverseProxy for Magento}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency('rack-livereload')
  spec.add_dependency 'rack'
  spec.add_dependency 'childprocess'
  spec.add_dependency 'rack-reverse-proxy'
end
