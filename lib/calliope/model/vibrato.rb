# frozen_string_literal: true

module Calliope
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
  end
end
