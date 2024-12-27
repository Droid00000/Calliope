# frozen_string_literal: true

module Calliope
  class Equalizer
    # @return [Integer]
    attr_reader :band

    # @return [Integer]
    attr_reader :gain

    # @param payload [Hash]
    def initialize(payload)
      @band = payload["band"]
      @gain = payload["gain"]
    end
  end
end
