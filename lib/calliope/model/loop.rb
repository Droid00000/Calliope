# frozen_string_literal: true

module Calliope
  # Easily loop with the queue.
  class Loop
    # @return [Symbol]
    attr_reader :type

    # @return [Track]
    attr_reader :forward

    # @!visibility private
    def initialize
      @forward = nil
      @type = :NORMAL
    end

    # Set the looping mode for this player.
    # @param mode [Symbol] One of NORMAL, QUEUE, or TRACK.
    def mode=(mode)
      @mode = mode if %i[NORMAL TRACK QUEUE].include?(mode)
    end

    # Whether this player is actively looping.
    # @return [Boolean] Whether the tracks are looping.
    def full?
      %i[TRACK QUEUE].include?(@mode) && @forward
    end

    # The media you want to loop.
    # @param forward [Playable, Track] A playable object or a track.
    # @param index [Integer] An optional index to loop from if this is a playable.
    def forward=(forward, index: 0)
      @forward, @index = forward, index
    end

    # Get the next track for this loop.
    # @return [Track, Playable] The next object.
    def shift
      if @type == :QUEUE
        @forward.tracks.shift.tap { |track| @forward.tracks << track }
      end

      if @type == :TRACK
        @forward.is_a?(Track) ? @forward : @forward.tracks.fetch(@index)
      end
    end
  end
end
