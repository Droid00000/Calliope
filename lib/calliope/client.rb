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

    # @return [String, nil]
    attr_reader :session_id

    # @return [String]
    attr_reader :client_name

    # @return [String]
    attr_reader :application_id
    alias_method :bot_id, :application_id

    # @param address [String] URL for connecting to the Lavalink node.
    # @param password [String] Password for connecting to the Lavalink node.
    # @param application_id [Integer] The snowflake of the application using the node.
    # @param session_id [String] ID of a previous lavalink session to resume if there's one.
    def initialize(address:, password:, application_id:, session_id: nil)
      @address = "#{address.chomp('/')}/v4"
      @players = Hash.new
      @password = password
      @session = session_id
      @application_id = application_id&.to_i
      @rest = ::API::Rest.new(@address, @password)
      @websocket = ::API::Socket.new(@bot_id, @address, @password, @session_id)
    end

    # Connects this player to the websocket.
    def connect
      @websocket.start
    end
  end
end
