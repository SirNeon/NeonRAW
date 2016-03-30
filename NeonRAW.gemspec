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
  spec.description   = 'SirNeon\'s wonderful API wrapper for Reddit.'
  spec.homepage      = 'https://gitlab.com/SirNeon/NeonRAW'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency             'typhoeus', '~> 0.7'
end
