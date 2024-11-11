# frozen_string_literal: true

module Calliope
  class Track
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

    # @return [Time]
    attr_reader :duration

    # @return [String]
    attr_reader :encoded

    # @param payload [Hash]
    # @param search [object]
    def initialize(payload, client)
      @client = client
      @name = payload['info']['title']
      @cover = payload['info']['artworkUrl']
      @artist = payload['info']['author']
      @source = payload['info']['uri']
      @encoded = payload['encoded']
      @playback = resolve_source unless payload['info']['sourceName'] == 'youtube'
      @duration = Time.at(payload['info']['length'])
    end

    # @return [String]
    def resolve_source
      @client.youtube("#{@name} #{@artist}").source
    end
  end
end
