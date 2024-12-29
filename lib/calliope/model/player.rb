# frozen_string_literal: true

module Calliope
  class Player
    # @return [Integer]
    attr_reader :ping

    # @return [String]
    attr_reader :track

    # @return [String]
    attr_reader :volume

    # @return [String]
    attr_reader :paused

    # @return [Hash]
    attr_reader :voice

    # @return [String]
    attr_reader :flters

    # @return [Integer]
    attr_reader :guild

    # @return [Boolean]
    attr_reader :connected

    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @voice = payload["voice"]
      @volume = payload["volume"]
      @paused = payload["paused"]
      @guild = payload["guildId"]
      @ping = payload["state"]["ping"]
      @connected = payload["state"]["connected"]
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end

    # Pause or unpause playback.
    # @param paused [Boolean] Whether this player should be currently paused.
    def paused=(paused)
      @client.http.modify_player(@guild, paused: paused)
    end
  end
end
