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

    # A block style builder for filters.
    class Builder
      # @return [Integer]
      attr_reader :volume

      # @return [Object]
      attr_accessor :karaoke

      # @return [Object]
      attr_accessor :tremolo

      # @return [Object]
      attr_accessor :vibrato

      # @return [Integer]
      attr_accessor :rotation

      # @return [Integer]
      attr_accessor :low_pass

      # @return [Object]
      attr_accessor :equalizer

      # @return [Object]
      attr_accessor :timescale

      # @return [Object]
      attr_accessor :distortion

      # @return [Object]
      attr_accessor :channel_mix

      # @!visibility private
      def initalize
        @volume = nil
        @karaoke = nil
        @tremolo = nil
        @vibrato = nil
        @rotation = nil
        @low_pass = nil
        @equalizer = nil
        @timescale = nil
        @distortion = nil
        @channel_mix = nil
      end

      # Add low pass to this builder.
      def low_pass(smoothing)
        @low_pass = { smoothing: smoothing }
      end

      # Add rotation to this builder.
      def rotation(rotation_hz)
        @rotation = { roationHz: rotation_hz }
      end

      # Add karaoke to this builder.
      def karaoke(**arguments)
        builder = Karaoke::Builder.new(arguments)

        yield builder if block_given?

        @karaoke = builder.to_h
      end

      # Add Tremolo to this builder.
      def tremolo(**arguments)
        builder = Tremolo::Builder.new(arguments)

        yield builder if block_given?

        @tremolo = builder.to_h
      end

      # Add vibrato this builder.
      def vibrato(**arguments)
        builder = Vibrato::Builder.new(arguments)

        yield builder if block_given?

        @vibrato = builder.to_h
      end

      # Add equalizer to this builder.
      def equalizer(**arguments)
        builder = Equalizer::Builder.new(arguments)

        @equalizer = [] if @equalizer.nil?

        yield builder if block_given?

        @equalizer << builder.to_h
      end

      # Add timescale to this builder.
      def timescale(**arguments)
        builder = Timescale::Builder.new(arguments)

        yield builder if block_given?

        @timescale = builder.to_h
      end

      # Add distortion to this builder.
      def distortion(**arguments)
        builder = Distortion::Builder.new(arguments)

        yield builder if block_given?

        @distortion = builder.to_h
      end

      # Add channel mix to this builder.
      def channel_mix(**arguments)
        builder = ChannelMix::Builder.new(arguments)

        yield builder if block_given?

        @channel_mix = builder.to_h
      end

      # @!visibility private
      def to_h
        { volume: @volume,
          equalizer: @equalizer,
          karaoke: @karaoke,
          timescale: @timescale,
          tremolo: @tremolo,
          vibrato: @vibrato,
          rotation: @rotation,
          distortion: @distortion,
          channelMix: @channel_mix,
          lowPass: @low_pass }.compact
      end
    end
  end
end
