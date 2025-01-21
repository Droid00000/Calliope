# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Base class for segment events.
    class SegmentsLoaded
      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :player

      # @return [Symbol]
      attr_reader :category

      # @return [Time]
      attr_reader :end_time

      # @return [Time]
      attr_reader :start_time

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @category = payload["segments"][0]["category"].to_sym
        @end_time = Time.at(payload["segments"][0]["end"] / 1000.0)
        @start_time = Time.at(payload["segments"][0]["start"] / 1000.0)
      end
    end

    # Base class for segment events.
    class SegmentSkipped
      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :player

      # @return [Symbol]
      attr_reader :category

      # @return [Time]
      attr_reader :end_time

      # @return [Time]
      attr_reader :start_time

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @category = payload["segment"]["category"].to_sym
        @end_time = Time.at(payload["segment"]["end"] / 1000.0)
        @start_time = Time.at(payload["segment"]["start"] / 1000.0)
      end
    end

    # Raised when a chapter is loaded.
    class ChaptersLoaded
      # @return [String]
      attr_reader :name

      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :player

      # @return [Time]
      attr_reader :duration

      # @return [Time]
      attr_reader :end_time

      # @return [Time]
      attr_reader :start_time

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @name = payload["chapters"][0]["name"]
        @end_time = Time.at(payload["chapters"][0]["end"] / 1000.0)
        @start_time = Time.at(payload["chapters"][0]["start"] / 1000.0)
        @duration = Time.at(payload["chapters"][0]["duration"] / 1000.0)
      end
    end

    # Raised when a chapter starts.
    class ChapterStarted
      # @return [String]
      attr_reader :name

      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :player

      # @return [Time]
      attr_reader :duration

      # @return [Time]
      attr_reader :end_time

      # @return [Time]
      attr_reader :start_time

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["guildId"].to_i
        @player = @client.players[@guild]
        @name = payload["chapters"][0]["name"]
        @end_time = Time.at(payload["chapter"]["end"] / 1000.0)
        @start_time = Time.at(payload["chapter"]["start"] / 1000.0)
        @duration = Time.at(payload["chapter"]["duration"] / 1000.0)
      end
    end
  end
end
