# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised whenever the voice websocket closes.
    class SocketClosed
      # @return [Integer]
      attr_reader :code

      # @return [Integer]
      attr_reader :guild

      # @return [Object]
      attr_reader :client

      # @return [String]
      attr_reader :reason

      # @return [Boolean]
      attr_reader :remote
      alias remote? remote

      # @!visibility private
      # @param payload [Hash]
      # @param client [Client]
      def initialize(payload, client)
        @client = client
        @code = payload["code"]
        @guild = payload["guildId"]
        @reason = payload["reason"]
        @remote = payload["byRemote"]
      end
    end
  end
end
