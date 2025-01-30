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

    # Equalizer builder.
    class Builder
      # @return [Integer]
      attr_accessor :band

      # @return [Integer]
      attr_accessor :gain

      # @!visibility private
      def initialize(payload)
        @band = payload[:band]
        @gain = payload[:gain]
      end

      # @!visibility private
      def to_h
        { band: @band, gain: @gain }.compact
      end
    end
  end
end
