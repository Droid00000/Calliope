# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Base class for track events.
    class TrackEvent
      include Calliope

      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :track

      # @return [Object]
      attr_reader :player

      # @!attribute [r] name
      #   @return [String] The name of the track.
      #   @see Track#name
      # @!attribute [r] isrc
      #   @return [String, nil] The ISRC code of the track, or nil.
      #   @see Track#isrc
      # @!attribute [r] cover
      #   @return [String] The artwork URL of the track.
      #   @see Track#cover
      # @!attribute [r] artist
      #   @return [String] the track's creator.
      #   @see Track#artist
      # @!attribute [r] source
      #   @return [String] the source URL of the track.
      #   @see Track#source
      # @!attribute [r] encoded
      #   @return [String] the Base64 encoded track.
      #   @see Track#encoded
      # @!attribute [r] position
      #   @return [Integer] The current position of the track in milliseconds.
      #   @see Track#position
      # @!attribute [r] duration
      #   @return [Integer] The duration of the track in milliseconds.
      #   @see Track#duration
      delegate :name, :isrc, :cover, :artist, :source, :encoded, :position, :duration, to: :track

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @track = Track.new(payload["track"])
      end
    end

    # Raised whenever a track begins playing.
    class TrackStart < TrackEvent
      # @return [Boolean]
      attr_reader :playing

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        super

        @playing = (@player&.playing = true)
      end
    end

    # Raised when a track stops playing.
    class TrackEnd < TrackEvent
      # @return [String]
      attr_reader :reason

      # @return [Boolean]
      attr_reader :playing

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        super

        @reason = payload["reason"]
        @playing = (@player&.playing = false)
        @player.queue.play(payload["reason"])
      end
    end

    # Raised when a track gets stuck playing.
    class TrackStuck < TrackEvent
      # @return [Integer]
      attr_reader :threshold

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        super

        @threshold = payload["thresholdMs"]
      end
    end

    # Raised when a track throws an error.
    class TrackError < TrackEvent
      # @return [String]
      attr_reader :cause

      # @return [String]
      attr_reader :message

      # @return [Boolean]
      attr_reader :playing

      # @return [String]
      attr_reader :severity

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        super

        @playing = (@player&.playing = false)
        @cause = payload["exception"]["cause"]
        @message = payload["exception"]["message"]
        @severitiy = payload["exception"]["severity"]
      end
    end
  end
end
