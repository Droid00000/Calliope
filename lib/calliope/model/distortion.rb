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
  end
end
