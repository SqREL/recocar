# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'recocar/version'

Gem::Specification.new do |spec|
  spec.name          = "recocar"
  spec.version       = Recocar::VERSION
  spec.authors       = ["Vasilij Melnychuk"]
  spec.email         = ["isqrel@gmail.com"]
  spec.description   = %q{Gem for reconition vehicle registration plates}
  spec.summary       = %q{Gem for reconition vehicle registration plates}
  spec.homepage      = "http://melnychuk.me"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-debugger"
  spec.add_dependency "rainbow"
  spec.add_dependency "fftw3"
end
