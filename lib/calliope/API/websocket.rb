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

      # @param user_id [Integer]
      # @param address [String]
      # @param password [String]
      # @param session_id [String, nil]
      # @param client_name [String, nil]
      def initialize(user_id:, address:, password:, session_id: nil, client_name: nil)
        @user_id = user_id&.to_i
        @address = "ws#{address.delete_prefix('http')}/websocket"
        @password = password
        @session_id = session_id
        @client_name = client_name || "Calliope/#{Calliope::VERSION}"
        @headers = headers.compact
      end

      # Set the headers used for connecting to the WS.
      def headers
        {
          'Authorization': @password,
          'User-Id': @user_id,
          'Client-Name': @client_name,
          'Session-Id': @session_id
        }
      end

      # https://lavalink.dev/api/websocket.html#player-update-op
      def handle_update(dispatch)
        State.new(dispatch)
      end

      # https://lavalink.dev/api/websocket.html#ready-op
      def handle_ready(dispatch)
        Ready.new(dispatch)
      end

      # https://lavalink.dev/api/websocket.html#stats-op
      def handle_stats(dispatch)
        Stats.new(dispatch)
      end

      # https://lavalink.dev/api/websocket.html#event-op
      def handle_event(dispatch)
        raise_event(dispatch)
      end

      # Handles a dispatch reccived over the Websocket.
      def handle_dispatch(dispatch)
        case dispatch['op'].to_sym
        when :playerUpdate
          handle_update(dispatch)
        when :ready
          handle_ready(dispatch)
        when :stats
          handle_stats(dispatch)
        when :event
          handle_event(dispatch)
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
