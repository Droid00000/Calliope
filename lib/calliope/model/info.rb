# frozen_string_literal: true

module Calliope
  class Info
    # @return [String]
    attr_reader :major_version

    # @return [String]
    attr_reader :patch_version

    # @return [String]
    attr_reader :jvm_version

    # @return [String]
    attr_reader :commit_sha

    # @return [Array<String>]
    attr_reader :filters

    # @return [Array<String>]
    attr_reader :sources

    # @return [String]
    attr_reader :version

    # @return [Hash]
    attr_reader :plugins

    # @return [String]
    attr_reader :semver

    # @return [String]
    attr_reader :branch

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @jvm_version = payload["jvm"]
      @filters = payload["filters"]
      @version = payload["lavaplayer"]
      @sources = payload["sourceManagers"]
      @semver = payload["version"]["semver"]
      @commit_sha = payload["git"]["commit"]
      @major_version = payload["version"]["major"]
      @patch_version = payload["version"]["patch"]
      @branch = payload["git"]["branch"]&.downcase
      @plugins = transform_plugins(payload["plugins"])
    end

    private

    # @!visibility private
    # Transforms the plugins array into a single hash.
    def transform_plugins(plugins)
      plugins.each_with_object({}) do |plugin, result|
        result[plugin["name"]] = plugin["version"]
      end
    end
  end
end
