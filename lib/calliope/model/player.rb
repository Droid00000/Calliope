# frozen_string_literal: true

module Calliope
  class Player
    # @return [Integer]
    attr_reader :ping

    # @return [Object]
    attr_reader :track

    # @return [String]
    attr_reader :volume

    # @return [String]
    attr_reader :paused
    alias paused? paused

    # @return [Hash]
    attr_reader :voice

    # @return [String]
    attr_reader :flters

    # @return [Integer]
    attr_reader :guild

    # @return [Integer]
    attr_reader :position

    # @return [Boolean]
    attr_accessor :playing

    # @return [Boolean]
    attr_reader :connected

    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @playing = false
      @voice = payload["voice"]
      @volume = payload["volume"]
      @paused = payload["paused"]
      @guild = payload["guildId"].to_i
      @ping = payload["state"]["ping"]
      @position = payload["state"]["position"]
      @connected = payload["state"]["connected"]
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end

    # Pause or unpause playback.
    # @param paused [Boolean] Whether this player should be currently paused.
    def paused=(paused)
      @client.http.modify_player(@guild, paused: paused)
      @paused = paused
    end

    # Set the volume of this player.
    # @param volume [Integer] Number between 0-1000.
    def volume=(volume)
      @client.http.modify_player(@guild, volume: volume)
      @volume = volume
    end

    # Set the position of the currently playing track.
    # @param position [Integer] The track position in milliseconds.
    def position=(position)
      @client.http.modify_player(@guild, position: position)
      @position = position
    end

    # Set the track that this player is playing.
    def track=(track)
      @client.http.modify_player(@guild, track: track.to_h)
    end

    # Set the queue used by the Lavalink player.
    def queue=(queue)
      @client.http.update_queue(@guild, type: "normal", tracks: queue)
    end

    private

    # @!visibility private
    # @note For internal use only.
    # Updates the player data with new data.
    def update_data(payload)
      @voice = payload["voice"] if payload["voice"]
      @track = Track.new(payload) if payload["track"]
      @volume = payload["volume"] if payload["volume"]
      @paused = payload["paused"] if payload["paused"]
      @playing = payload["playing"] if payload["playing"]
      @guild = payload["guildId"]&.to_i if payload["guildId"]
      @ping = payload["state"]["ping"] if payload.dig("state", "ping")
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
      @connected = payload["state"]["connected"] if payload.dig("state", "connected")
    end
  end
end
