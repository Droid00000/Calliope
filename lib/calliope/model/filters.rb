# frozen_string_literal: true

module Calliope
  # Main filter class.
  class Filters
    # @return [Integer]
    attr_reader :volume

    # @return [Object]
    attr_reader :karaoke

    # @return [Object]
    attr_reader :tremolo

    # @return [Object]
    attr_reader :vibrato

    # @return [Hash]
    attr_reader :plugins

    # @return [Integer]
    attr_reader :rotation

    # @return [Integer]
    attr_reader :low_pass

    # @return [Object]
    attr_reader :equalizer

    # @return [Object]
    attr_reader :timescale

    # @return [Object]
    attr_reader :distortion

    # @return [Object]
    attr_reader :channel_mix

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)      
      @volume = payload["volume"] if payload["volume"]
      @karaoke = Karaoke.new(payload["karaoke"]) if payload["karaoke"]
      @tremolo = Tremolo.new(payload["tremolo"]) if payload["tremolo"]
      @vibrato = Vibrato.new(payload["vibrato"]) if payload["vibrato"]
      @plugins = payload["pluginFilters"] if payload["pluginFilters"]
      @rotation = payload["rotation"]["rotationHz"] if payload["rotation"]
      @low_pass = payload["lowPass"]["smoothing"] if payload payload["lowPass"]
      @equalizer = payload["equalizer"].map { |hash| Equalizer.new(hash) } if payload["equalizer"]
      @timescale = Timescale.new(payload["timescale"]) if payload["timescale"]
      @distortion = Distortion.new(payload["distortion"]) if payload["distortion"]
      @channel_mix = ChannelMix.new(payload["channelMix"]) if payload["channelMix"]
    end
  end
end
