# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised when the ready event is received.
    class Ready
      # @return [Object]
      attr_reader :client

      # @return [Boolean]
      attr_reader :resumed

      # @return [String]
      attr_reader :session_id

      # @!visibility private
      def initialize(payload, client)
        @client = client
        @resumed = payload["resumed"]
        @session_id = payload["sessionId"]
        @client.resumed = payload["resumed"]
        @client.session = payload["sessionId"]
        @client.http.session = payload["sessionId"]
      end
    end
  end
end
