# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synx/version'

Gem::Specification.new do |spec|
  spec.name          = 'synx'
  spec.version       = Synx::VERSION
  spec.authors       = ['Mark Larsen']
  spec.email         = ['mark@venmo.com']
  spec.summary       = %q{A command-line tool that reorganizes your Xcode project folder to match your Xcode groups}
  spec.description   = <<-DESC
                       A command-line tool that reorganizes your Xcode project folder to match your Xcode groups
                       Synx parses your .xcodeproj to build the same group structure out on the file system.
                       DESC
  spec.homepage      = 'https://github.com/venmo/synx'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /docs\// }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'pry', '~> 0.12'

  spec.add_dependency 'clamp', '~> 1.3'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'xcodeproj', '~> 1.7'
end
