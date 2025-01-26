# frozen_string_literal: true

module Calliope
  # A lavalink player for a guild.
  class Player
    # @return [Time]
    attr_reader :time

    # @return [Integer]
    attr_reader :ping

    # @return [Track, nil]
    attr_reader :track

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
    attr_reader :connected

    # @!visibility private
    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @voice = payload["voice"]
      @volume = payload["volume"]
      @paused = payload["paused"]
      @queue = TrackQueue.new(self)
      @guild = payload["guildId"].to_i
      @ping = payload["state"]["ping"]
      @time = payload["state"]["time"]
      @position = payload["state"]["position"]
      @connected = payload["state"]["connected"]
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end

    # Pause or unpause playback.
    # @param paused [Boolean] Whether this player should be currently paused.
    def paused=(paused)
      update_data(@client.http.modify_player(guild, paused: paused))
    end

    # The track end time in milliseconds.
    # @param end_time [Integer] The track end time in milliseconds.
    def end_time=(time)
      update_data(@client.http.modify_player(guild, end_time: time))
    end

    # Whether the next track should override.
    # @param replace [Boolean] Whether to override or not.
    def no_replace=(replace)
      update_data(@client.http.modify_player(guild, replace: replace))
    end

    # Set the position of the currently playing track.
    # @param position [Integer] The track position in milliseconds.
    def position=(position)
      update_data(@client.http.modify_player(guild, position: position))
    end

    # Delete this player. Immediately stops playback.
    def delete
      @client.players.delete(guild).tap { @client.http.destroy_player(guild) }
    end

    # Set the volume of this player.
    # @param volume [Integer] Number between 0-1000.
    def volume=(volume)
      update_data(@client.http.modify_player(guild, volume: volume.clamp(0, 1000)))
    end

    # A hash containing the metadata of a player.
    def export
      { track: @track&.to_h, position: @position, queue: @queue.to_h, volume: @volume }.compact
    end

    # Set the track that this player is playing.
    # @param track [Track, nil] The track object to set. Nil stops the current track.
    def track=(track)
      return @track if update_data(@client.http.modify_player(guild, track: track&.to_h || Track.null))
    end

    # Import data from an export.
    def import(hash)
      update_data(@client.http.update_player(@guild, hash.delete(:queue))); @queue.import(hash[:queue])
    end

    # Update the filters for this player. Overrides all existing filters.
    # @param filters [Hash] A hash of filters to set for the player. Overrides the builder.
    # @yieldparam [Filters::Builder] Yields the filter builder for easy creation of a filter.
    def filters=(filters = nil)
      builder = Filters::Builder.new.tap { |builder| yield builder }

      update_data(@client.http.modify_player(guild, filters: filters || builder.to_h))
    end

    # Check if a player is currently playing something.
    # @return [Boolean] Whether this player is currently playing something.
    def playing?
      @track && !@paused
    end

    # Guild ID based comparison.
    def ==(other)
      other.is_a?(Player) ? other.guild == @guild : false
    end

    private

    # @!visibility private
    # @note For internal use only.
    # Updates the track data with new data.
    def update_track(payload)
      payload ? @track = Track.new(track) : @track = nil
    end

    # @!visibility private
    # @note For internal use only.
    # Updates the player data with new data.
    def update_data(payload)
      @voice = payload["voice"] if payload.key?("voice")
      @volume = payload["volume"] if payload.key?("volume")
      @paused = payload["paused"] if payload.key?("paused")
      @ping = payload["state"]["ping"] if payload.key?("state")
      @time = payload["state"]["time"] if payload.key?("state")
      @guild = payload["guildId"]&.to_i if payload.key?("guildId")
      @track = payload["track"].nil? ? nil : Track.new(payload["track"])
      @connected = payload["state"]["connected"] if payload.key?("state")
      @filters = Filters.new(payload["filters"]) unless payload["filters"].empty?
    end
  end
end
