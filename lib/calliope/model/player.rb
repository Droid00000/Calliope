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
      update_data(@client.http.modify_player(@guild, track: track.to_h))
    end

    # Get the currently playing track.
    def track
      update_data(@client.http.get_player(@guild))
      @track
    end

    # Fetches the queue for this current player.
    def queue
      response = @client.http.get_queue(@guild)["tracks"]

      response.map { |track| Track.new(track) } unless response.empty?
    end

    # Set the queue used by the Lavalink player.
    # By default this won't override the current queue.
    def queue=(tracks)
      @client.http.add_queue_tracks(@guild, tracks) if queue

      @client.http.update_queue(@guild, tracks: tracks) unless queue
    end

    # Stops the currently playing track.
    def stop_playing
      @client.http.modify_player(@guild, track: Track.null, replace: false)
      @track = nil
    end

    # Skip to the next track in the queue.
    # @param index [Integer] Position of the track.
    # @return [Track] The track that's currently playing.
    def next(index)
      stop_playing

      if index.nil? || index.zero?
        @client.http.move_queue_track(@guild, 0, 0)
      else
        @client.http.move_queue_track(@guild, index, 0)
      end

      @client.http.delete_queue_track(@guild, index + 1)

      track
    end

    # Go back to the previous track in the queue.
    # @return [Track, nil] The Track that was previously playing or nil.
    def previous_track
      begin
        @client.http.previous_queue_track(@guild)
      rescue Calliope::NotFound
        raise "There isn't a queue to play from!"
      end

      stop_playing
      @client.http.previous_queue_track(@guild)
      track
    end

    # Shuffles the current queue.
    def shuffle_queue
      @client.http.update_queue(@guild, tracks: queue.shuffle.map(&:to_h))
      queue.first
    end

    # Deletes the current queue.
    def delete_queue
      @client.http.delete_queue(@guild)
    end

    # A hash containing the metadata of a player.
    def export
      { track: track, position: position, queue: queue, volume: volume }.compact
    end

    # Import data from an export.
    def import(hash)
      # To-Do
    end

    private

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
