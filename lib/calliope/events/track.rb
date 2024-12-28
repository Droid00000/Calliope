# frozen_string_litral: true

module Calliope
  # Generic class for events.
  module Events
    # Raised whenever a track begins playing.
    class TrackStart
      # @return [Object]
      attr_reader :track

      delegate :isrc, :name, :cover, :artist, :source, :encoded, :position, :duration, to: :track

      # @param payload [Hash]
      # @param client [Hash]
      def initialize(payload, client)
        @client = client
        @track = Track.new(payload['track'], client)
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

        @reason = payload['reason']
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

        @threshold = payload['thresholdMs']
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

        @cause = payload['exception']['cause']
        @message = payload['exception']['message']
        @severitiy = payload['exception']['severity']
      end
    end
  end
end
