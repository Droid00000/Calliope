# frozen_string_literal: true

module Calliope
  # The distortion filter.
  class Distortion
    # @return [Integer]
    attr_reader :sin_offset

    # @return [Integer]
    attr_reader :sin_scale

    # @return [Integer]
    attr_reader :cos_offset

    # @return [Integer]
    attr_reader :cos_scale

    # @return [Integer]
    attr_reader :tan_offset

    # @return [Integer]
    attr_reader :tan_scale

    # @return [Integer]
    attr_reader :offset

    # @return [Integer]
    attr_reader :scale

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @sin_offset = payload["sinOffset"]
      @sin_scale = payload["sinScale"]
      @cos_offset = payload["cosOffset"]
      @cos_scale = payload["cosScale"]
      @tan_offset = payload["tanOffset"]
      @tan_scale = payload["tanScale"]
      @offset = payload["offset"]
      @scale = payload["scale"]
    end

    # Distortion builder.
    class Builder
      # @return [Integer]
      attr_accessor :sin_offset

      # @return [Integer]
      attr_accessor :sin_scale

      # @return [Integer]
      attr_accessor :cos_offset

      # @return [Integer]
      attr_accessor :cos_scale

      # @return [Integer]
      attr_accessor :tan_offset

      # @return [Integer]
      attr_accessor :tan_scale

      # @return [Integer]
      attr_accessor :offset

      # @return [Integer]
      attr_accessor :scale

      # @!visibility private
      # @param payload [Hash]
      def initialize(payload)
        @sin_offset = payload[:sin_offset]
        @sin_scale = payload[:sin_scale]
        @cos_offset = payload[:cos_offset]
        @cos_scale = payload[:cos_scale]
        @tan_offset = payload[:tan_offset]
        @tan_scale = payload[:tan_scale]
        @offset = payload[:offset]
        @scale = payload[:scale]
      end

      # @!visibility private
      def to_h
        { offset: @offset,
          scale: @scale,
          sinOffset: @sin_offset,
          sinScale: @sin_scale,
          cosOffset: @cos_offset,
          cosScale: @cos_scale,
          tanOffset: @tan_offset,
          tanScale: @tan_scale }.compact
      end
    end
  end
end
