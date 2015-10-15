# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synx/version'

Gem::Specification.new do |spec|
  spec.name          = "synx"
  spec.version       = Synx::VERSION
  spec.authors       = ["Mark Larsen"]
  spec.email         = ["mark@venmo.com"]
  spec.summary       = %q{A command-line tool that reorganizes your Xcode project folder to match your Xcode groups}
  spec.description   = <<-DESC
                       A command-line tool that reorganizes your Xcode project folder to match your Xcode groups
                       Synx parses your .xcodeproj to build the same group structure out on the file system.
                       DESC
  spec.homepage      = "https://github.com/venmo/synx"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /docs\// }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "pry", "~> 0.9"

  spec.add_dependency "clamp", "~> 0.6"
  spec.add_dependency "colorize", "~> 0.7"
  spec.add_dependency "xcodeproj", "~> 0.28.2"
end
