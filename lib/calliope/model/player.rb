# frozen_string_literal: true

module Calliope
  class Player
    # @return [String]
    attr_reader :track

    # @return [String]
    attr_reader :volume

    # @return [String]
    attr_reader :paused

    # @return [String]
    attr_reader :state

    # @return [Object]
    attr_reader :voice

    # @return [String]
    attr_reader :flters

    # @return [Integer]
    attr_reader :guild

    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @state = payload["state"]
      @voice = payload["voice"]
      @volume = payload["volume"]
      @paused = payload["paused"]
      @guild = payload["guildId"]
      @filters = Filters.new(payload["filters"])
    end
  end
end
