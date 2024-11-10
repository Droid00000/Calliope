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
          'Authorization': @password,
          'User-Id': @user_id,
          'Client-Name': @client_name
        }
      end

      # Handle every dispatch reccived over the WS.
      def handle_dispatch(dispatch)
        case dispatch["op"]&.to_sym
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

      def start_ws
        Thread.new do
          websocket = WebSocket::Client::Simple.connect(@address, headers: @headers)

          websocket.on(:message) do |payload|
            handle_dispatch(JSON.parse(payload.data))
          end

          loop do
            websocket.send(STDIN.gets.strip)
          end
        end
      end
    end
  end
end
