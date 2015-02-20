# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pawa/version'

Gem::Specification.new do |spec|
  spec.name          = "pawa"
  spec.version       = Pawa::VERSION
  spec.authors       = ["Kevin Giguere"]
  spec.email         = ["kev.giguere.l@gmail.ca"]
  spec.summary       = "PAWA : Porting Algorithms With Annotations"
  spec.description   = "PAWA is meant to ease maintaining a library that must be written in two different languages. PAWA will transform files of language A with replace operations and line substitutions you put in your files in the form of comments. Then it will send them to your favorite diff viewer to compare with your existing files of language B. This is essentially telling you where you must make modifications in language B to port the modifications you did in language A."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
