# frozen_string_literal: true

module Calliope
  # The vibrato filter.
  class Vibrato
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

    # Vibrato builder.
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
