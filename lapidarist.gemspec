lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lapidarist/version"

Gem::Specification.new do |spec|
  spec.name        = "lapidarist"
  spec.version     = Lapidarist::VERSION
  spec.authors     = ["Mark Gangl"]
  spec.email       = ["mark@attackcorp.com"]

  spec.summary     = %q{Automatically update ruby gem dependencies.}
  spec.description = %q{Sit back, relax, and allow Lapidarist to do the heavy lifiting and update your ruby gem dependencies for you.}
  spec.homepage    = "https://github.com/attack/lapidarist"
  spec.license     = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
