# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'patternmaker/version'

Gem::Specification.new do |gem|
  gem.name          = "patternmaker"
  gem.version       = Patternmaker::VERSION
  gem.authors       = ["Matthew Williams"]
  gem.email         = ["matt@aetherical.com"]
  gem.description   = %q{Programatically create weaving patterns}
  gem.summary       = %q{Used by Weft of the Moon}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency "chunky_png"
  gem.add_runtime_dependency "active_support"
end
