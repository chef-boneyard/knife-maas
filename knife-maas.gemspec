# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef/maas/version'

Gem::Specification.new do |spec|
  spec.name          = 'knife-maas'
  spec.version       = Chef::Maas::VERSION
  spec.authors       = ['Chef Partner Engineering']
  spec.email         = ['jj@chef.io']
  spec.summary       = %q{A knife plugin to interact with MAAS}
  spec.description   = %q{A knife plugin to interact with MAAS}
  spec.homepage      = 'https://github.com/chef-partners/knife-maas'
  spec.license       = 'Apache2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chef', '~> 12.0'
  spec.add_dependency 'oauth', '~> 0.4'
  spec.add_dependency 'bson', '~> 3.0'
  spec.add_dependency 'xml-simple', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 0.30.0'
end
