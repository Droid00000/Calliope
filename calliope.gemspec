# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "calliope"
  spec.authors = ["Droid00000"]
  spec.version = "1.0.0"

  spec.license = "Apache-2.0"
  spec.summary = "Lavalink API in Ruby."
  spec.homepage = "https://github.com/droid00000/calliope"
  spec.description = "Wrapper for the Lavalink API in Ruby."

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/droid00000/calliope/issues",
    "changelog_uri" => "https://github.com/droid00000/calliope/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/droid00000/calliope/wiki",
    "source_code_uri" => "https://github.com/droid00000/calliope",
    "rubygems_mfa_required" => "true"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |files|
    files.match(%r{^(test|spec|bin|features|.git|.github/appveyor/Gemfile)/})
  end

  spec.bindir = "exe"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.3"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency "faraday", "~> 2.12.2"
  spec.add_dependency "websocket-driver", "~> 0.7.6"
end
