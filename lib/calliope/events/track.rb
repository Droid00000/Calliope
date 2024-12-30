# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised whenever a track begins playing.
    class TrackStart
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
        @guild = payload["guildId"]&.to_i
        @player = @client.players[@guild]
        @track = Track.new(payload["track"])
      end
    end

    # Raised when a track stops playing.
    class TrackEnd < TrackStart
      # @return [String]
      attr_reader :reason

      # @param payload [Hash]
      # @param client [Hash]
      def initialize(payload, client)
        super

        @reason = payload["reason"]
        payload["playing"] = false
      end
    end

    # Raised when a track gets stuck playing.
    class TrackStuck < TrackStart
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
    class TrackError < TrackStart
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
