# frozen_string_literal: true

module Calliope
  # The channel mix filter.
  class ChannelMix
    # @return [Integer]
    attr_reader :left_to_left

    # @return [Integer]
    attr_reader :left_to_right

    # @return [Integer]
    attr_reader :right_to_left

    # @return [Integer]
    attr_reader :right_to_right

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @left_to_left = payload["leftToLeft"]
      @left_to_right = payload["leftToRight"]
      @right_to_left = payload["rightToLeft"]
      @right_to_right = payload["rightToRight"]
    end

    # Channel Mix builder.
    class Builder
      # @return [Integer]
      attr_accessor :left_to_left

      # @return [Integer]
      attr_accessor :left_to_right

      # @return [Integer]
      attr_accessor :right_to_left

      # @return [Integer]
      attr_accessor :right_to_right

      # @!visibility private
      def initialize(payload)
        @left_to_left = payload[:left_to_left]
        @left_to_right = payload[:left_to_right]
        @right_to_left = payload[:right_to_left]
        @right_to_right = payload[:right_to_right]
      end

      # @!visibility private
      def to_h
        { leftToLeft: @left_to_left,
          leftToRight: @left_to_right,
          rightToLeft: @right_to_left,
          rightToRight: @right_to_right }.compact
      end
    end
  end
end
