# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised whenever we get the stats OP.
    class Stats
      # @return [Integer]
      attr_reader :allocated_memory

      # @return [Integer]
      attr_reader :reserved_memory

      # @return [Integer]
      attr_reader :playing_players

      # @return [Integer]
      attr_reader :deficit_frames

      # @return [Integer]
      attr_reader :nulled_frames

      # @return [Integer]
      attr_reader :total_players

      # @return [Integer]
      attr_reader :lavalink_load

      # @return [Integer]
      attr_reader :free_memory

      # @return [Integer]
      attr_reader :used_memory

      # @return [Integer]
      attr_reader :sent_frames

      # @return [Integer]
      attr_reader :system_load

      # @return [Integer]
      attr_reader :cpu_cores

      # @return [Time]
      attr_reader :uptime

      # @return [Object]
      attr_reader :client

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @total_players = payload["players"]
        @cpu_cores = payload["cpu"]["cores"]
        @free_memory = payload["memory"]["free"]
        @used_memory = payload["memory"]["used"]
        @system_load = payload["cpu"]["systemLoad"]
        @playing_players = payload["playingPlayers"]
        @uptime = Time.at(payload["uptime"] / 1000.0)
        @lavalink_load = payload["cpu"]["lavalinkLoad"]
        @allocated_memory = payload["memory"]["allocated"]
        @reserved_memory = payload["memory"]["reservable"]

        unless payload["frameStats"].nil?
          @sent_frames = payload["frameStats"]["sent"]
          @nulled_frames = payload["frameStats"]["nulled"]
          @deficit_frames = payload["frameStats"]["deficit"]
        end
      end
    end
  end
end
