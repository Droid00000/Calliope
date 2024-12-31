# frozen_string_literal: true

module Calliope
  class Track
    # @return [String]
    attr_reader :isrc

    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :cover

    # @return [String]
    attr_reader :artist

    # @return [String]
    attr_reader :source

    # @return [String]
    attr_reader :encoded

    # @return [Time]
    attr_reader :duration

    # @return [Integer]
    attr_reader :position

    # @return [String]
    attr_reader :is_stream

    # @return [String]
    attr_reader :identifier

    # @return [String]
    attr_reader :source_name

    # @param payload [Hash]
    def initialize(payload)
      @isrc = payload["info"]["isrc"]
      @name = payload["info"]["title"]
      @cover = payload["info"]["artworkUrl"]
      @artist = payload["info"]["author"]
      @source = payload["info"]["uri"]
      @encoded = payload["encoded"]
      @duration = payload["info"]["length"]
      @position = payload["info"]["position"]
      @is_stream = payload["info"]["isStream"]
      @identifier = payload["info"]["identifier"]
      @source_name = payload["info"]["sourceName"]
    end

    # Converts this track into a hash that can used for playback.
    def to_h
      { encoded: @encoded }
    end

    # A string representation of the track time.
    def strftime
      Time.at(@duration / 1000.0).utc.strftime("%M:%S")
    end
  end
end
