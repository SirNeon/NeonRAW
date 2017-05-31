# coding: utf-8
# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'NeonRAW/version'

Gem::Specification.new do |spec|
  spec.name          = 'NeonRAW'
  spec.version       = NeonRAW::VERSION
  spec.authors       = ['SirNeon']
  spec.email         = ['sirneon618@gmail.com']
  spec.summary       = 'A Reddit API wrapper for Ruby.'
  spec.description   = 'SirNeon\'s wonderful API wrapper for Reddit. BETA'
  spec.homepage      = 'https://github.com/SirNeon618/NeonRAW'
  spec.license       = 'MPL-2.0'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency             'typhoeus', '~> 1.0'
end
