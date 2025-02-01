# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Base class for track events.
    class TrackEvent
      extend Forwardable

      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :track

      # @return [Object]
      attr_reader :player

      def_delegator :@track, :name, :name
      def_delegator :@track, :isrc, :isrc
      def_delegator :@track, :cover, :cover
      def_delegator :@track, :artist, :artist
      def_delegator :@track, :source, :source
      def_delegator :@track, :encoded, :encoded
      def_delegator :@track, :position, :position
      def_delegator :@track, :duration, :duration

      # @!visibility private
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @track = Track.new(payload["track"])
      end
    end

    # Raised whenever a track begins playing.
    class TrackStart < TrackEvent
      # @!visibility private
      def initialize(payload, client)
        super

        @player.__send__(:update_track, @track)
      end
    end

    # Raised when a track stops playing.
    class TrackEnd < TrackEvent
      # @return [String]
      attr_reader :reason

      # @!visibility private
      def initialize(payload, client)
        super

        @reason = payload["reason"]
        @player.__send__(:update_track, nil)
        @player.queue.play(payload["reason"])
      end
    end

    # Raised when a track gets stuck playing.
    class TrackStuck < TrackEvent
      # @return [Integer]
      attr_reader :threshold

      # @!visibility private
      def initialize(payload, client)
        super

        @threshold = payload["thresholdMs"]
        @player.__send__(:update_track, nil)
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
      
      # @return [String]
      attr_reader :stack_trace

      # @!visibility private
      def initialize(payload, client)
        super

        @player.__send__(:update_track, nil)
        @cause = payload["exception"]["cause"]
        @message = payload["exception"]["message"]
        @severitiy = payload["exception"]["severity"]
        @stack_trace = payload["exception"]["causeStackTrace"]
      end
    end
  end
end
