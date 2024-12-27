# frozen_string_literal: true

module Calliope
  class Tremolo
    # @return [Integer]
    attr_reader :depth

    # @return [Integer]
    attr_reader :frequency

    # @param payload [Hash]
    def initialize(payload)
      @depth = payload["depth"]
      @frequency = payload["frequency"]
    end
  end
end
