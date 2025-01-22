# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Base class for sponsor events.
    class SponsorEvent
      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :player

      # @!visibility private
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
      end
    end

    # Raised when a segment is skipped.
    class SegmentSkipped < SponsorEvent
      # @return [Segment]
      attr_reader :segment

      # @!visibility private
      def initialize(payload, client)
        super

        @segment = Segment.new(payload["segment"])
      end
    end

    # Raised when a chapter starts.
    class ChapterStarted < SponsorEvent
      # @return [Chapter]
      attr_reader :chapter

      # @!visibility private
      def initialize(payload, client)
        super

        @chapter = Chapter.new(payload["chapter"])
      end
    end

    # Raised when segments are loaded.
    class SegmentsLoaded < SponsorEvent
      # @return [Array<Segment>]
      attr_reader :segments

      # @!visibility private
      def initialize(payload, client)
        super

        @segments = payload["segments"].map { |data| Segment.new(data) }
      end
    end

    # Raised when a chapter is loaded.
    class ChaptersLoaded < SponsorEvent
      # @return [Array<Chapter>]
      attr_reader :chapters

      # @!visibility private
      def initialize(payload, client)
        super

        @chapters = payload["chapters"].map { |data| Chapter.new(data) }
      end
    end
  end
end
