# frozen_string_literal: true

require 'websocket-client-simple'

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

      def initialize(user_id, address, password)
        @user_id = user_id.to_s
        @address = "ws#{address.delete_prefix('http')}/websocket"
        @password = password.to_s
        @client_name = "Calliope/#{Calliope::VERSION}"
        @headers = prepare_headers
      end

      # Prepare the headers used for connecting to the WS.
      def prepare_headers
        {
          Authorization: @password,
          'User-Id': @user_id,
          'Client-Name': @client_name
        }
      end

      # Handle every dispatch reccived over the WS.
      def handle_dispatch(dispatch)
        case dispatch['op'].to_sym
        when :playerUpdate
          handle_update(dispatch)
        when :ready
          handle_ready(dispatch)
        when :stats
          handle_stats(dispatch)
        when event
          handle_event(dispatch)
        end
      end

      # https://lavalink.dev/api/websocket.html#player-update-op
      def handle_update(dispatch)
        Calliope::State.new(dispatch)
      end

      # https://lavalink.dev/api/websocket.html#ready-op
      def handle_ready(dispatch)
        Calliope::Ready.new(dispatch)
      end

      # https://lavalink.dev/api/websocket.html#stats-op
      def handle_stats(dispatch)
        Calliope::Stats.new(dispatch)
      end

      # Starts the Web-socket thread used for connecting to the Lavalink servers.
      def start
        Thread.new do
          websocket = WebSocket::Client::Simple.connect(@address, headers: @headers)

          websocket.on(:message) do |payload|
            handle_dispatch(JSON.parse(payload.data))
          end

          loop do
            websocket.send($stdin.gets.strip)
          end
        end
      end
    end
  end
end
