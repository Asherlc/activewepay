# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activewepay/version'

Gem::Specification.new do |spec|
  spec.name          = "activewepay"
  spec.version       = Activewepay::VERSION
  spec.authors       = ["Asher Cohen"]
  spec.email         = ["asherlc@asherlc.com"]
  spec.description   = %q{ActiveModel style WePay interface.}
  spec.summary       = %q{{ActiveModel style WePay interface.}}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
