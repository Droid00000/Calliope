# frozen_string_literal: true

module Calliope
  module API
    class Websocket
      # @return [String]
      attr_reader :name

      # @return [String]
      attr_reader :address

      # @return [String]
      attr_reader :user_id

      # @return [String]
      attr_reader :password

      # @return [String]
      attr_reader :client_name

      # @param user_id [Integer] Snowflake ID of the bot that uses the lavalink node.
      # @param address [String] wss:// address used for connecting to the lavalink node.
      # @param password [String] Password used for connecting to the lavalink node.
      # @param session_id [String, nil] ID of the previous session to resume.
      # @param client_name [String, nil] Name of the client connecting to the lavalink node.
      def initialize(user_id:, address:, password:, session_id: nil, client_name: nil)
        @user_id = user_id&.to_i
        @address = "ws#{address.delete_prefix('http')}/websocket"
        @password = password
        @session_id = session_id
        @client_name = client_name || "Calliope/#{Calliope::VERSION}"
        @headers = headers.compact
      end

      # Creates the headers hash.
      def headers
        {
          'Authorization': @password,
          'User-Id': @user_id,
          'Client-Name': @client_name,
          'Session-Id': @session_id
        }
      end

      # Handles a dispatch from the Websocket.
      def handle_dispatch(dispatch)
        case dispatch['op'].to_sym
        when :playerUpdate
          State.new(dispatch)
        when :ready
          Ready.new(dispatch)
        when :stats
          Stats.new(dispatch)
        when :event
          Event.new(dispatch)
        end
      end

      # Starts the WS thread used for connecting to the Lavalink node.
      def start
        Thread.new do
          websocket = WebSocket::Client::Simple.connect(@address, headers: @headers)

          websocket.on(:message) { |frame| handle_dispatch(JSON.parse(frame.data)) }

          loop { websocket.send($stdin.gets.strip) }
        end
      end
    end
  end
end
