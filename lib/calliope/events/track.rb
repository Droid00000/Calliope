# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Base class for track events.
    class TrackEvent
      extend Forwardable

      # @return [Object]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :track

      # @return [Object]
      attr_reader :player

      def_delegator :@track, :isrc, :name
      def_delegator :@track, :cover, :artist
      def_delegator :@track, :source, :encoded
      def_delegator :@track, :position, :duration

      # @param payload [Hash]
      # @param client [Hash]
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

      # @param payload [Hash]
      # @param client [Hash]
      def initialize(payload, client)
        super

        @playing = (@player.playing = true)
      end
    end

    # Raised when a track stops playing.
    class TrackEnd < TrackEvent
      # @return [String]
      attr_reader :reason

      # @param payload [Hash]
      # @param client [Hash]
      def initialize(payload, client)
        super

        @player.playing = false
        @reason = payload["reason"]
      end
    end

    # Raised when a track gets stuck playing.
    class TrackStuck < TrackEvent
      # @return [Integer]
      attr_reader :threshold

      # @param payload [Hash]
      # @param client [Hash]
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

      # @return [String]
      attr_reader :severity

      # @param payload [Hash]
      # @param client [Hash]
      def initialize(payload, client)
        super

        @cause = payload["exception"]["cause"]
        @message = payload["exception"]["message"]
        @severitiy = payload["exception"]["severity"]
      end
    end
  end
end
