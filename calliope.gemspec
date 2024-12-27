# frozen_string_literal: true

require_relative "lib/calliope/version"

Gem::Specification.new do |spec|
  spec.name = "calliope"
  spec.version = Calliope::VERSION
  spec.authors = ["DroidDevelopment"]
  spec.email = ["johnship2876@gmail.com"]

  spec.summary = "Lavalink API in Ruby."
  spec.description = "A wrapper for the audio sending node, Lavalink in Ruby."
  spec.homepage = "https://github.com/droid00000/calliope"
  spec.required_ruby_version = ">= 3.3"
  spec.license = "Apache-2.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/droid00000/calliope/issues",
    "changelog_uri" => "https://github.com/droid00000/calliope/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/droid00000/calliope/wiki",
    "source_code_uri" => "https://github.com/droid00000/calliope",
    "rubygems_mfa_required" => "true"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|bin|features|.git|.github/appveyor/Gemfile)/})
  end

  spec.bindir = "exe"
  spec.require_paths = ["lib"]
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency "faraday"
  spec.add_dependency 'faye-websocket'

  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
