# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synx/version'

Gem::Specification.new do |spec|
  spec.name          = "synx"
  spec.version       = Synx::VERSION
  spec.authors       = ["Mark Larsen"]
  spec.email         = ["mark@venmo.com"]
  spec.summary       = %q{A command-line tool that automagically reorganizes your Xcode project folder to match your Xcode groups.}
  spec.description   = <<-DESC
                       A command-line tool that automagically reorganizes your Xcode project folder to match your Xcode groups.
                       Parses the .xcodeproj to build the group structure out on the file system.
                       DESC
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /docs\// }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "clamp"
  spec.add_dependency "colored"
  spec.add_dependency "xcodeproj"
end
