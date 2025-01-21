# frozen_string_literal: true

module Calliope
  # A lavalink player for a guild.
  class Player
    # @return [Integer]
    attr_reader :ping

    # @return [String]
    attr_reader :volume

    # @return [String]
    attr_reader :paused
    alias paused? paused

    # @return [Queue]
    attr_reader :queue

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
    alias playing? playing

    # @return [Boolean]
    attr_reader :connected

    # @!visibility private
    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @playing = false
      @voice = payload["voice"]
      @volume = payload["volume"]
      @paused = payload["paused"]
      @queue = TrackQueue.new(self)
      @guild = payload["guildId"].to_i
      @ping = payload["state"]["ping"]
      @position = payload["state"]["position"]
      @connected = payload["state"]["connected"]
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end

    # Pause or unpause playback.
    # @param paused [Boolean] Whether this player should be currently paused.
    def paused=(paused)
      update_data(@client.http.modify_player(@guild, paused: paused))
    end

    # Set the volume of this player.
    # @param volume [Integer] Number between 0-1000.
    def volume=(volume)
      update_data(@client.http.modify_player(@guild, volume: volume))
    end

    # Set the position of the currently playing track.
    # @param position [Integer] The track position in milliseconds.
    def position=(position)
      update_data(@client.http.modify_player(@guild, position: position))
    end

    # Set the track that this player is playing.
    def track=(track)
      return if track.nil?

      update_data(@client.http.modify_player(@guild, track: track&.to_h))
    end

    # Get the currently playing track.
    def track
      update_data(@client.http.get_player(@guild))
      @track
    end

    # A hash containing the metadata of a player.
    def export
      { track: track, position: position, queue: queue, volume: volume }.compact
    end

    # Import data from an export.
    def import(hash)
      # To-Do
    end

    # Guild ID based comparison.
    def ==(other)
      return false unless other.is_a?(Player)

      other.guild == @guild
    end

    private

    def can_start_player_tracks?
     !track? && !paused? && !playing?
    end

    # @!visibility private
    # @note For internal use only.
    # Updates the player data with new data.
    def update_data(payload)
      @voice = payload["voice"] if payload.key?("voice")
      @volume = payload["volume"] if payload.key?("volume")
      @paused = payload["paused"] if payload.key?("paused")
      @playing = payload["playing"] if payload.key?("playing")
      @ping = payload["state"]["ping"] if payload.key?("state")
      @guild = payload["guildId"]&.to_i if payload.key?("guildId")
      @track = payload["track"].nil? ? nil : Track.new(payload["track"])
      @connected = payload["state"]["connected"] if payload.key?("state")
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end
  end
end
