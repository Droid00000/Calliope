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

      # @param payload [Hash]
      def initialize(payload)
        puts payload
        @total_players = payload["players"]
        @cpu_cores = payload["cpu"]["cores"]
        @free_memory = payload["memory"]["free"]
        @used_memory = payload["memory"]["used"]
        @system_load = payload["cpu"]["systemLoad"]
        @playing_players = payload["playingPlayers"]
        @sent_frames = payload["frameStats"]["sent"] unless payload["frameStats"].nil?
        @uptime = Time.at(payload["uptime"] / 1000.0)
        @lavalink_load = payload["cpu"]["lavalinkLoad"]
        @nulled_frames = payload["frameStats"]["nulled"] unless payload["frameStats"].nil?
        @deficit_frames = payload["frameStats"]["deficit"] unless payload["frameStats"].nil?
        @allocated_memory = payload["memory"]["allocated"]
        @reserved_memory = payload["memory"]["reservable"]
      end
    end
  end
end
