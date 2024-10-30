# frozen_string_literal: true

module Calliope
  class Song
    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :cover

    # @return [String]
    attr_reader :artist

    # @return [String]
    attr_reader :source

    # @return [Object]
    attr_reader :search

    # @return [String]
    attr_reader :playback

    # @return [String]
    attr_reader :duration

    # @param payload [Hash]
    # @param search [object]
    def initialize(payload, search)
      @search = search
      @name = payload['data']['info']['title']
      @cover = payload['data']['info']['artworkUrl']
      @artist = payload['data']['info']['author']
      @source = payload['data']['info']['uri']
      @playback = resolve_source unless youtube(payload)
      @duration = resolve_duration(payload['data']['info']['length'])
    end

    # @return [String]
    def resolve_source
      @search.source("#{@name} #{@artist}").playback
    end

    # @param payload [Hash]
    def youtube(payload)
      payload['data'][0].dig('info', 'sourceName') == 'youtube' if payload['data'].is_a?(Array)
      payload['data']['tracks'][0].dig('info',
                                       'sourceName') == 'youtube' if payload['data'].is_a?(Hash) && payload['data']['tracks']
      payload['data'].dig('info',
                          'sourceName') == 'youtube' if payload['data'].is_a?(Hash) && payload['data']['tracks'].nil?
    end
  end
end
