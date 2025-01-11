# frozen_string_literal: true

module Calliope
  # The Equalizer filter.
  class Equalizer
    # @return [Integer]
    attr_reader :band

    # @return [Integer]
    attr_reader :gain

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @band = payload["band"]
      @gain = payload["gain"]
    end
  end
end
