# frozen_string_literal: true

module Calliope
  class Karaoke
    # @return [Integer]
    attr_reader :level

    # @return [Integer]
    attr_reader :mono_level

    # @return [Integer]
    attr_reader :filter_band

    # @return [Integer]
    attr_reader :filter_width

    # @param payload [Hash]
    def initialize(payload)
      @level = payload["level"]
      @mono_level = payload["monoLevel"]
      @filter_band = payload["filterBand"]
      @filter_width = payload["filterWidth"]
    end
  end
end
