# frozen_string_literal: true

module Calliope
  # A queue of tracks.
  class TrackQueue
    # @return [Boolean]
    attr_accessor :loop

    # @return [Player]
    attr_accessor :player

    # @return [Array<Tracks>]
    attr_accessor :tracks

    # @return [Array<Tracks>]
    attr_accessor :history

    # @!visibility private
    def initialize(player)
      @player = player
      @tracks = Array.new
      @history = Array.new

      # @!attribute [r] last
      #   @return [Track] The last track in the queue.
      #   @see Array#last
      # @!attribute [r] first
      #   @return [Track] The first track in the queue.
      #   @see Array#first
      # @!attribute [r] size
      #   @return [Integer] The amount of tracks in the queue.
      #   @see Array#size
      # @!attribute [r] sample
      #   @return [Track] A random track in the queue.
      #   @see Array#sample
      # @!attribute [r] count
      #   @return [Integer] The amount of tracks in the queue.
      #   @see Array#count
      # @!attribute [r] empty?
      #   @return [Boolean] Whether the queue is empty or not.
      #   @see Array#empty?
      # @!attribute [r] clear
      #   @return [Array] Remove all the tracks in the queue.
      #   @see Array#clear
      # @!attribute [r] shuffle
      #   @return [Array] Shuffles the tracks in the queue.
      #   @see Array#shuffle
      # @!attribute [r] replace
      #   @return [Array] Replace all the tracks in the queue.
      #   @see Array#replace
      %i[last, first, size, sample, count, empty?, clear, shuffle, replace].each do |method|
        define_method(method) { |*arguments| @tracks.send(method, *arguments) }
      end
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
      return if %w[stopped cleanup replaced].include?(reason) || empty?

      @player.track = @tracks.shift.tap { |track| @history << track }
    end
  end
end
