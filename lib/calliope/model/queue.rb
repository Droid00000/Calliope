# frozen_string_literal: true

module Calliope
  # A queue of tracks.
  class TrackQueue
    # Allows delegation.
    extend Forwardable

    # @return [Loop]
    attr_accessor :looped

    # @return [Player]
    attr_accessor :player

    # @return [Array<Tracks>]
    attr_accessor :tracks

    # @return [Array<Tracks>]
    attr_accessor :history

    def_delegator :@tracks, :last, :last
    def_delegator :@tracks, :size, :size
    def_delegator :@tracks, :count, :count
    def_delegator :@tracks, :clear, :clear
    def_delegator :@tracks, :first, :first
    def_delegator :@tracks, :sample, :sample
    def_delegator :@tracks, :empty?, :empty?
    def_delegator :@tracks, :length, :length
    def_delegator :@tracks, :shuffle, :shuffle
    def_delegator :@tracks, :replace, :replace

    # @!visibility private
    def initialize(player)
      @player = player
      @looped = Loop.new
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

      play(0) unless @player.paused? || @player.playing?
    end

    # Check if there's still object in the queue.
    # @return [Boolean] If we can start the next track.
    def full?
      !@tracks.empty? || @looped.full?
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
    # @return [Track, Array<Track>] The new track object that's now playing.
    def previous
      return unless @history.fetch(1, nil)

      @player.track = @history[1].tap { |track| @history.unshift(track) }
    end

    # Play the next track in the queue. Immediatly overrides the current one.
    # @return [Track, Array<Track>] The new track object that's now playing.
    def next
      return unless full?

      @player.track = @tracks&.shift&.tap { |track| @history.unshift(track) }
    end

    # Skip to a track at a specific index.
    # @param index [Integer] The index of the track to skip to.
    # @param destructive [Boolean] Whether to remove previous tracks.
    # @return [Track] The new track object that's now playing.
    def skip(index, destructive: false)
      return unless @tracks.fetch(index, nil)

      @player.track = @tracks.delete_at(index).tap { |track| @history.unshift(track) } unless destructive

      @player.track = remove(0, amount: index + 1).tap { |tracks| @history.unshift(*tracks) }.last if destructive
    end

    # Convert the queue into tracks that can be re-used and re-imported later down the line.
    # @return [Hash] A hash containing all the data about this queue excluding the looped track.
    def to_h
      { history: @history.map(&:encoded), tracks: @tracks.map(&:encoded), looped: @looped.type }
    end

    # Get and play a random track from the queue.
    # @return [Track] The track object that's now playing.
    def random
      return unless full?

      @player.track = @tracks.delete_at(rand(@tracks.size)).tap { |track| @history.unshift(track) }
    end

    # @!visibility private
    # @note For internal use only.
    # Start the next track in the queue upon recciving the track end event.
    # @return [Array<Tracks>] The the entire track history so far at this point.
    def play(reason)
      return if %w[stopped cleanup replaced].include?(reason) || !full?

      @player.track = @looped.shift.tap { |track| @history.unshift(track) } if @looped.full?

      @player.track = @tracks.shift.tap { |track| @history.unshift(track) } unless @looped.full?
    end

    # @!visibility private
    # @note For internal use only.
    # Import the previously exported queue back into the player.
    # @param [Hash] The hash containing the metadata about the queue.
    # @return [self] The new imported values from the old exported ones.
    def import(hash)
      @looped.type = hash[:looped] if hash[:looped]

      @history = @player.client.decode(hash[:history]).tap { add(@player.client.decode(hash[:tracks])) }
    end
  end
end
