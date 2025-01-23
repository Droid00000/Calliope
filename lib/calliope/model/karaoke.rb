# frozen_string_literal: true

module Calliope
  # The karaoke filter.
  class Karaoke
    # @return [Integer]
    attr_reader :level

    # @return [Integer]
    attr_reader :mono_level

    # @return [Integer]
    attr_reader :filter_band

    # @return [Integer]
    attr_reader :filter_width

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @level = payload["level"]
      @mono_level = payload["monoLevel"]
      @filter_band = payload["filterBand"]
      @filter_width = payload["filterWidth"]
    end

    # Karaoke builder.
    class Builder
      # @return [Integer]
      attr_accessor :level

      # @return [Integer]
      attr_accessor :mono_level

      # @return [Integer]
      attr_accessor :filter_band

      # @return [Integer]
      attr_accessor :filter_width

      # @!visibility private
      def initialize(payload)
        @level = payload[:level]
        @mono_level = payload[:mono_level]
        @filter_band = payload[:filter_band]
        @filter_width = payload[:filter_width]
      end

      # @!visibility private
      def to_h
        { level: @level,
          monoLevel: @mono_level,
          filterBand: @filter_band,
          filterWidth: @filter_width }.compact
      end
    end
  end
end
