# frozen_string_literal: true

require "json"
require "websocket-client-simple"

# The websocket client internally used by calliope.
module Calliope
  module API
    class Socket
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
      def initialize(address, password, user_id, session_id, client)
        @@client = client
        @user_id = user_id&.to_i
        @address = "ws#{address.delete_prefix("http")}/websocket"
        @password = password
        @session_id = session_id
        @client_name = "Calliope/#{Calliope::VERSION}"
        @headers = headers.compact
      end

      # Creates the headers hash.
      def headers
        {
          Authorization: @password,
          "User-Id": @user_id,
          "Client-Name": @client_name,
          "Session-Id": @session_id
        }
      end

      # Handles a dispatch from the Websocket.
      def self.dispatch(dispatch)
        puts dispatch
        case dispatch['op'].to_sym
        when :playerUpdate
          @@client.__send__(:notify_update, dispatch)
        when :ready
          @@client.__send__(:notify_ready, dispatch)
        when :stats
          @@client.__send__(:notify_stats, dispatch)
        when :event
          @@client.__send__(:notify_event, dispatch)
        end
      end

      # Starts the WS thread used for connecting to the Lavalink node.
      def start
        Thread.new do
          websocket = WebSocket::Client::Simple.connect(@address, headers: @headers)

          websocket.on(:message) do |message|
          begin
            d = JSON.parse(message.data)
            handle_dispatch(d)
          rescue StandardError => e
            puts e.message
          end
        end

          loop { websocket.send($stdin.gets.chomp) }
        end
      end
    end
  end
end
