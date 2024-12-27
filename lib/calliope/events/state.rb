# frozen_string_literal: true

module Calliope
  class State
    # @return [Integer]
    attr_reader :ping

    # @return [Integer]
    attr_reader :time

    # @return [Integer]
    attr_reader :guild

    # @return [Integer]
    attr_reader :position

    # @return [Boolean]
    attr_reader :connected

    # @param payload [Hash]
    def initialize(payload)
      @guild = payload["GuildId"]
      @ping = payload["state"]["ping"]
      @time = payload["state"]["time"]
      @position = payload["state"]["position"]
      @connected = payload["state"]["connected"]
    end
  end
end
