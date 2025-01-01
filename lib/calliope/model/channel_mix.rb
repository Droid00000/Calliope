# frozen_string_literal: true

module Calliope
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
  end
end
