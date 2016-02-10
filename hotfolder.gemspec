# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "hotfolder"
  spec.version       = "0.0.1"
  spec.authors       = ["DMG Runner"]
  spec.email         = ["runner@spe.sony.com"]

  spec.summary       = %q{Provides a generic hotfolder mixin}
  spec.description   = %q{Including the hotfolder module allows any class to become a hotfolder class.}
  spec.homepage      = "https://github.com/spedmg/hotfolder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "dotenv"
end
