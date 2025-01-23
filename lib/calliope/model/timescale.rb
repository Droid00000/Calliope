# frozen_string_literal: true

module Calliope
  # The timescale filter.
  class Timescale
    # @return [Integer]
    attr_reader :rate

    # @return [Integer]
    attr_reader :speed

    # @return [Integer]
    attr_reader :pitch

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @rate = payload["rate"]
      @speed = payload["speed"]
      @pitch = payload["pitch"]
    end

    # Timescale builder.
    class Builder
      # @return [Integer]
      attr_accessor :rate

      # @return [Integer]
      attr_accessor :speed

      # @return [Integer]
      attr_accessor :pitch

      # @!visibility private
      # @param payload [Hash]
      def initialize(payload)
        @rate = payload[:rate]
        @speed = payload[:speed]
        @pitch = payload[:pitch]
      end

      # @!visibility private
      def to_h
        { rate: @rate, speed: @speed, pitch: @pitch }.compact
      end
    end
  end
end
