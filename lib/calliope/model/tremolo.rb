# frozen_string_literal: true

module Calliope
  # The tremolo filter.
  class Tremolo
    # @return [Integer]
    attr_reader :depth

    # @return [Integer]
    attr_reader :frequency

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @depth = payload["depth"]
      @frequency = payload["frequency"]
    end

    # Tremolo builder.
    class Builder
      # @return [Integer]
      attr_accessor :depth

      # @return [Integer]
      attr_accessor :frequency

      # @!visibility private
      # @param payload [Hash]
      def initialize(payload)
        @depth = payload[:depth]
        @frequency = payload[:frequency]
      end

      # @!visibility private
      def to_h
        { depth: @depth, frequency: @frequency }.compact
      end
    end
  end
end
