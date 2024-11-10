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
    attr_reader :free_memory

    # @return [Integer]
    attr_reader :used_memory

    # @return [Integer]
    attr_reader :cpu_cores

    # @return [Integer]
    attr_reader :uptime

    # @param payload [Hash]
    def initialize(payload)
      @allocated_memory = payload['memory']['allocated']
      @reserved_memory = payload['memory']['reservable']
      @playing_players = payload['playingPlayers']
      @total_players = payload['players']
      @free_memory = payload['memory']['free']
      @used_memory = payload['memory']['used']
      @cpu_cores = payload['cpu']['cores']
      @uptime = payload['uptime']
    end
  end
end
