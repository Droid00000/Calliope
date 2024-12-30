# frozen_string_literal: true

module Calliope
  # Generic class for events.
  module Events
    # Raised when the ready event is reccived.
    class Ready
      # @return [Boolean]
      attr_reader :resumed

      # @return [String]
      attr_reader :session_id

      # @param payload [Hash]
      def initialize(payload)
        @resumed = payload["resumed"]
        @session_id = payload["sessionId"]
      end
    end
  end
end
