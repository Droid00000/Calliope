# frozen_string_literal: true

module Calliope
  # A queue of tracks.
  class TrackQueue
    extend Forwardable

    # @return [Boolean]
    attr_accessor :loop

    # @return [Player]
    attr_accessor :player

    # @return [Array<Tracks>]
    attr_accessor :tracks

    # @return [Array<Tracks>]
    attr_accessor :history

    def_delegator :@tracks, :last, :first
    def_delegator :@tracks, :size, :sample
    def_delegator :@tracks, :count, :empty?
    def_delegator :@tracks, :clear, :shuffle
    def_delegator :@tracks, :length, :replace

    # @!visibility private
    def initialize(player)
      @player = player
      @tracks = Array.new
      @history = Array.new
    end

    # Add tracks to the end of the queue. Will start the next track by default.
    # @param tracks [Array<Track>, Track, Playable] Track(s) or playable objects.
    def add(tracks)
      @tracks << tracks if tracks.is_a?(Track)

      if tracks.is_a?(Array)
        tracks.flatten.each { |track| add(track) }
      end

      if tracks.is_a?(Playable)
        tracks.tracks.each { |track| @tracks << track }
      end

      play(0) if !@player.track && !@player.paused?
    end

    # Move the position of a track in the array.
    # @param position [Integer] The current index of the track.
    # @param index [Integer] The new index of the track.
    def move(position, index)
      return unless @tracks.fetch(position, nil)

      @tracks.insert(index, remove(position))
    end

    # Get a specific index or the whole queue.
    # @param index [Integer, nil] The index to get.
    # @return [Track, Array<Track>] The specified index or the whole array.
    def get(index: nil)
      index ? @tracks.fetch(index, nil) : @tracks
    end

    # Remove tracks from a specific index with an amount.
    # @param index [Integer] The starting index to remove tracks at.
    # @param amount [Integer, nil] The amount of tracks to remove, or nil.
    # @param invert [Boolean] Whether the first elements should be dropped instead.
    def remove(index, amount: nil, invert: false)
      return @tracks.drop(index + 1) if invert

      amount ? @tracks.slice!(index, amount) : @tracks.delete_at(index)
    end

    # Play the previous track in the queue. Immediatly overrides the current one.
    # @return [Array<Tracks>] The the entire track history so far at this point.
    def previous
      return unless @history.fetch(-2, nil)

      @player.track = @history[-2].tap { |track| @history << track }
    end

    # Play the next track in the queue. Immediatly overrides the current one.
    # @return [Array<Tracks>] The the entire track history so far at this point.
    def next
      return if empty?

      @player.track = @tracks&.shift&.tap { |track| @history << track }
    end

    # @!visibility private
    # @note For internal use only.
    # Start the next track in the queue upon recciving the track end event.
    # @return [Array<Tracks>] The the entire track history so far at this point.
    def play(reason)
      return if %w[stopped cleanup replaced].include?(reason) || @tracks.empty?

      @player.track = @tracks.shift.tap { |track| @history << track }
    end
  end
end
