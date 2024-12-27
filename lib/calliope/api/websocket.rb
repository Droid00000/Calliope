# frozen_string_literal: true

require 'uri'
require 'json'
require 'socket'
require 'websocket/driver'

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
        @client = client
        @driver = ::WebSocket::Driver.client(self)
        @driver.set_header('User-Id', user_id&.to_i)
        @driver.set_header('Authorization', password)
        @driver.on(:message, &method(:handle_dispatch))
        @address = URI.parse(uri.to_s).tap { |u| u.scheme = 'ws' }
        @driver.set_header('Session-Id', session_id) if session_id
        @driver.set_header('Client-Name', "Calliope/#{Calliope::VERSION}")
      end

      # Handles a dispatch from the Websocket.
      def handle_dispatch(dispatch)
        case JSON.parse(dispatch)['op'].to_sym
        when :playerUpdate
          @client.__send__(:notify_update, JSON.parse(dispatch))
        when :ready
          @client.__send__(:notify_ready, JSON.parse(dispatch))
        when :stats
          @client.__send__(:notify_stats, JSON.parse(dispatch))
        when :event
          @client.__send__(:notify_event, JSON.parse(dispatch))
        end
      end

      # Read data from the TCP socket.
      # @param [Integer] length The maximum length to read at once.
      def parse_data
        @tcp.readpartial(4096)
      end

      # Used internally by the websocket driver.
      def url
        @address.to_s
      end

      # Starts the WS thread used for connecting to the Lavalink node.
      def start
        Thread.new do
          @socket = TCPSocket.new(@address.host || localhost, @address.port)

          @driver.parse(parse_data) until false

          @driver.start
        end
      end
    end
  end
end
