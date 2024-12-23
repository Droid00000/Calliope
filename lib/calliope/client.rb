# frozen_string_literal: true

# Used to access the Lavalink API.
module Calliope
  class Client
    # @return [String]
    attr_reader :address

    # @return [Hash<Integer => Player>]
    attr_reader :players

    # @return [String]
    attr_reader :password

    # @return [Object]
    attr_reader :websocket

    # @param address [String] URL for connecting to the Lavalink node.
    # @param password [String] Password for connecting to the Lavalink node.
    # @param application_id [Integer] The snowflake of the application using the node.
    # @param session_id [String] ID of a previous lavalink session to resume if there's one.
    def initialize(address:, password:, application_id:, session_id: nil)
      @address = "#{address.chomp('/')}/v4"
      @password = password
      @players = {}
      @states = {}
      @mutex = Mutex.new
      @rest = ::API::Rest.new(@address, @password, self)
      @websocket = ::API::Socket.new(@bot_id, @address, @password, session_id, application_id, self)
    end

    # Connects this player to the websocket.
    def login
      @websocket.start
    end

    # Connect to a lavalink node.
    # @param guild [String] ID of the guild to connect to.
    # @param token [string] Voice token of the server.
    # @param session [String] Session ID of the server.
    # @param endpoint [String] Endpoint of the server.
    def connect(guild, token: nil, session: nil, endpoint: nil)
      @mutex.synchronize do
        @states[guild][:sessionId] = session if session
        @states[guild][:endpoint] = endpoint if endpoint
        @states[guild][:token] = token if token
      end

      if @states[guild][:session] && @states[guild][:token]
        @players[guild] = Player.new(@rest.modify_player(@session, guild, state: @states[guild]), self)
        @states.delete(guild)
      end
    end
  end
end
