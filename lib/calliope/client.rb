# frozen_string_literal: true

require "json"
require "socket"
require "faraday"
require "forwardable"
require "websocket/driver"

require_relative "model/info"
require_relative "api/routes"
require_relative "api/client"
require_relative "model/track"
require_relative "model/player"
require_relative "events/ready"
require_relative "events/state"
require_relative "events/stats"
require_relative "events/track"
require_relative "events/voice"
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
    # @return [API::Client]
    attr_accessor :http

    # @return [API::Socket]
    attr_accessor :socket

    # @return [String]
    attr_accessor :session

    # @return [String]
    attr_accessor :address

    # @return [Hash<Integer => Player>]
    attr_accessor :players

    # @return [String]
    attr_accessor :password

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
      @socket = API::Socket.new(@address, @password, application_id, session_id, self)
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

      player = @http.modify_player(guild, voice: @states[guild])
      @players[guild] = Player.new(player, self)
      @states.delete(guild)
    end

    def encode_query(query)
      return query unless query.match?(/^(?:https?:\/\/)?(?:www\.)?youtu.be\/([a-zA-Z0-9\-_]+)$/)
    
      query = query.sub("?feature=shared", "").strip
    
      query.insert(query.index("e") + 2, "watch?v=")
    
      query.sub("youtu.be", "youtube.com")
    end

    # Performs a search on a given query.
    # @param query [String] The item to search for.
    # @return [Playable] The playable object.
    def search(query)
      Playable.new(@http.youtube(encode_query(query)), self)
    end

    # Decodes a bunch of encoded tracks into a playable object.
    # @param tracks [Array<String>, String] The encoded tracks to deocde.
    # @return [Playable] The playable object resulting from these tracks.
    def decode(*tracks)
      if tracks.flatten.size == 1
        Track.new(@http.decode_track(tracks.flatten), self)
      else
        Playable.new(@http.decode_tracks(tracks.flatten), self)
      end
    end

    # Delete a player.
    # @param guild [Integer, String] ID of the guild to delete the player for.
    def delete_player(guild)
      @players.delete(guild)
      @http.destroy_player(guild)
    end

    private

    # @!visibility private
    # Generic handler for the event dispatch event.
    def notify_event(data)
      case data["type"].to_sym
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

    # @!visibility private
    # Internal handler for the update event.
    def notify_update(data)
      Calliope::Events::State.new(data, self)
    end

    # @!visibility private
    # Internal handler for the stats event.
    def notify_stats(data)
      Calliope::Events::Stats.new(data, self)
    end

    # @!visibility private
    # Internal handler for the ready event.
    def notify_ready(data)
      Calliope::Events::Ready.new(data, self)
    end

    # @!visibility private
    # Internal handler for the track end event.
    def track_end(data)
      Calliope::Events::TrackEnd.new(data, self)
    end

    # @!visibility private
    # Internal handler for the track start event.
    def track_start(data)
      Calliope::Events::TrackStart.new(data, self)
    end

    # @!visibility private
    # Internal handler for the track stuck event.
    def track_stuck(data)
      Calliope::Events::TrackStuck.new(data, self)
    end

    # @!visibility private
    # Internal handler for the socket closed event.
    def websocket_close(data)
      Calliope::Events::SocketClosed.new(data, self)
    end

    # @!visibility private
    # Internal handler for the track excepction event.
    def track_exception(data)
      Calliope::Events::TrackException.new(data, self)
    end
  end
end
