# frozen_string_literal: true

module Calliope
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

    # @param payload [Hash]
    def initialize(payload)
      @volume = payload["volume"]
      @karaoke = Karaoke.new(payload["karaoke"])
      @tremolo = Tremolo.new(payload["tremolo"])
      @vibrato = Vibrato.new(payload["vibrato"])
      @plugins = payload["pluginFilters"]
      @rotation = payload["rotation"]["rotationHz"]
      @low_pass = payload["lowPass"]["smoothing"]
      @equalizer = payload["equalizer"].map { |hash| Equalizer.new(hash) }
      @timescale = Timescale.new(payload["timescale"])
      @distortion = Distortion.new(payload["distortion"])
      @channel_mix = ChannelMix.new(payload["channelMix"])
    end
  end
end
