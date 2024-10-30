# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'calliope/version'

Gem::Specification.new do |spec|
  spec.name          = 'calliope'
  spec.version       = Calliope::VERSION
  spec.authors       = %w[droid00000]
  spec.email         = ['']

  spec.summary       = 'Lavalink API for Ruby'
  spec.description   = 'A Ruby implementation of the Lavalink (https://lavalink.dev/api/rest) API.'
  spec.homepage      = 'https://github.com/Droid00000/Calliope'
  spec.license       = 'Apache 2.0'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/Droid00000/Calliope',
    'rubygems_mfa_required' => 'true'
  }

  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.12.0'
  spec.add_dependency 'json', '~> 2.7.4'

  spec.required_ruby_version = '>= 3.1'

  spec.add_development_dependency 'bundler', '>= 1.10', '< 3'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
end
