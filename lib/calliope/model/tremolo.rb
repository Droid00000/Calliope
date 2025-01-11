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
  end
end
