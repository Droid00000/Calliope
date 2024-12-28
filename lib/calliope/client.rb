# frozen_string_literal: true

require_relative "version"
require_relative "model/info"
require_relative "api/routes"
require_relative "api/client"
require_relative "model/track"
require_relative "model/player"
require_relative "events/ready"
require_relative "events/state"
require_relative "events/stats"
require_relative "api/websocket"
require_relative "model/tremolo"
require_relative "model/vibrato"
require_relative "model/filters"
require_relative "model/karaoke"
require_relative "model/playable"
require_relative "model/equalizer"
require_relative "model/timescale"
require_relative "model/distortion"
require_relative "model/channel_mix"

module Calliope
  # Used to access the Lavalink API.
  class Client
    # @return [Object]
    attr_reader :http

    # @return [String]
    attr_reader :session

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
    def initialize(address, password, application_id, session_id: nil)
      @address = "#{address}/v4"
      @password = password
      @players = {}
      @states = {}
      @session = nil
      @mutex = Mutex.new
      @http = API::HTTP.new(@address, @password)
      @websocket = API::Socket.new(@address, @password, application_id, session_id, self)
    end

    # Connects this player to the websocket.
    def login
      @websocket.start
    end

    # Checks if there's an active player.
    # @param id [Integer] ID of a guild.
    def player?(id)
      @players.key?(id)
    end

    # Connect to a lavalink node.
    # @param guild [String] ID of the guild to connect to.
    # @param token [string] Voice token of the server.
    # @param session [String] Session ID of the server.
    # @param endpoint [String] Endpoint of the server.
    def connect(guild, token: nil, session: nil, endpoint: nil)
      @mutex.synchronize do
        @states[guild] ||= {}
        @states[guild][:sessionId] = session if session
        @states[guild][:endpoint] = endpoint if endpoint
        @states[guild][:token] = token if token
      end

      return unless @states[guild][:sessionId] && @states[guild][:token]

      player = @http.modify_player(@session, guild.to_s, voice: @states[guild])
      @players[guild] = Player.new(player, self)
      @states.delete(guild)
    end

    # Performs a search on a given query.
    # @param query [String] The item to search for.
    # @return [Playable, Nil] The playable object or nil.
    def search(query)
      map_results(@http.youtube(query))
    end

    private

    # Maps the results of tracks.
    # @param result [Hash]
    def map_results(result)
      case result['loadType']
      when "playlist"
        Playable.new(result, :playlist, self)
      when "search"
        Playable.new(result, :search, self)
      when "track"
        Playable.new(result, :single, self)
      when "error"
        nil
      when "empty"
        nil
      end
    end

    # Internal handler for the event dispatch event.
    def notify_event(data)
      case data[:type].to_sym
      when :TrackEndEvent
        track_end(data)
      when :TrackStuckEvent
        track_stuck(data)
      when :TrackStartEvent
        track_start(data)
      when :TrackExceptionEvent
        track_exception(data)
      when :WebsocketClosedEvent
        websocket_close(data)
      end
    end

    # Internal handler for the ready event.
    def notify_ready(data)
      @session = data['sessionId']
    end

    # Internal handler for the update event.
    def notify_update(data)
      State.new(data)
    end

    # Internal handler for the stats event.
    def notify_stats(data)
      Stats.new(data)
    end
  end
end
