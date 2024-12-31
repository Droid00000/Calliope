# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised when the player state is dispatched.
    class State
      # @return [Object]
      attr_reader :client

      # @return [Integer]
      attr_reader :ping

      # @return [Integer]
      attr_reader :time

      # @return [Integer]
      attr_reader :guild

      # @return [Integer]
      attr_reader :position

      # @return [Boolean]
      attr_reader :connected

      # @param payload [Hash]
      def initialize(payload, client)
        @client = client
        @guild = payload["GuildId"]
        @ping = payload["state"]["ping"]
        @time = payload["state"]["time"]
        @position = payload["state"]["position"]
        @connected = payload["state"]["connected"]
      end
    end
  end
end
