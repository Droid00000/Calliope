# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised when the player state is dispatched.
    class State
      # @return [Client]
      attr_reader :client

      # @return [Integer]
      attr_reader :ping

      # @return [Integer]
      attr_reader :time

      # @return [Player]
      attr_reader :player

      # @return [Integer]
      attr_reader :guild

      # @return [Integer]
      attr_reader :position

      # @return [Boolean]
      attr_reader :connected

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @guild = payload["GuildId"].to_i
        @ping = payload["state"]["ping"]
        @time = payload["state"]["time"]
        @player = @client.players[@guild]
        @player.__send__(:update_data, payload)
        @position = payload["state"]["position"]
        @connected = payload["state"]["connected"]
      end
    end
  end
end
