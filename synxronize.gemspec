# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synxronize/version'

Gem::Specification.new do |spec|
  spec.name          = "synxronize"
  spec.version       = Synxronize::VERSION
  spec.authors       = ["Mark Larsen"]
  spec.email         = ["mark@venmo.com"]
  spec.summary       = %q{A command-line tool that reorganizes your project files into folders that match Xcode's group structure.}
  spec.description   = <<-DESC
                       A command-line tool to reorganize your project files to match Xcode's group structure. 
                       Parses the .xcodeproj to build the group structure out on the file system.
                       DESC
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "clamp"
  spec.add_dependency "xcodeproj"
end
