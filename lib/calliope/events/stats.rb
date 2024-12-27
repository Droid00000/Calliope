# frozen_string_literal: true

module Calliope
  class Stats
    # @return [Array<String>]
    attr_reader :allocated_memory

    # @return [String]
    attr_reader :reserved_memory

    # @return [String]
    attr_reader :playing_players

    # @return [String]
    attr_reader :total_players

    # @return [Integer]
    attr_reader :deficit_frames

    # @return [Integer]
    attr_reader :nulled_frames

    # @return [Integer]
    attr_reader :free_memory

    # @return [Integer]
    attr_reader :used_memory

    # @return [Integer]
    attr_reader :sent_frames

    # @return [Integer]
    attr_reader :cpu_cores

    # @return [Time]
    attr_reader :uptime

    # @param payload [Hash]
    def initialize(payload)
      # @allocated_memory = payload["memory"]["allocated"]
      # @reserved_memory = payload["memory"]["reservable"]
      # @playing_players = payload["playingPlayers"]
      # @total_players = payload["players"]
      # @deficit_frames = payload["frameStats"]["deficit"]
      # @nulled_frames = payload["frameStats"]["nulled"]
      # @free_memory = payload["memory"]["free"]
      # @used_memory = payload["memory"]["used"]
      # @cpu_cores = payload["cpu"]["cores"]
      # @sent_frames = payload["frameStats"]["sent"]
      # @uptime = Time.at(payload["uptime"])
    end
  end
end
