# frozen_string_literal: true

require "json"
require "socket"
require "faraday"
require "event_emitter"
require "websocket/driver"

require_relative "model/loop"
require_relative "model/info"
require_relative "api/routes"
require_relative "api/client"
require_relative "model/queue"
require_relative "model/track"
require_relative "model/logger"
require_relative "model/player"
require_relative "events/block"
require_relative "events/ready"
require_relative "events/state"
require_relative "events/stats"
require_relative "events/track"
require_relative "events/voice"
require_relative "model/segment"
require_relative "model/chapter"
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
    include EventEmitter

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

    # @return [Boolean]
    attr_accessor :resumed

    # @return [String]
    attr_accessor :password

    # @param address [String] URL for connecting to the Lavalink node.
    # @param password [String] Password for connecting to the Lavalink node.
    # @param application_id [Integer] The snowflake of the application using the node.
    # @param session_id [String] ID of a previous lavalink session to resume if there's one.
    # @param logging [Symbol] The log mode of the library. This has to be enabled manually.
    def initialize(address, password, application_id, session_id: nil, logging: :off)
      @address = "#{address}/v4"
      @password = password
      @players = Hash.new
      @states = Hash.new
      @mutex = Mutex.new
      @logger = Logger.new(logging)
      @http = API::HTTP.new(@address, @password)
      @socket = API::Socket.new(@address, @password, application_id, session_id, self)
    end

    # Connect to a lavalink node.
    # @param guild [String] ID of the guild to connect to.
    # @param token [string] Voice token of the server.
    # @param session [String] Session ID of the server.
    # @param endpoint [String] Endpoint of the server.
    def connect(guild, token: nil, session: nil, endpoint: nil)
      @mutex.synchronize do
        @states[guild] ||= {}
        @states[guild].merge!(to_voice(token, endpoint, session))
      end

      return unless @states[guild].keys.count == 3

      player = @http.modify_player(guild, voice: @states[guild])
      @players[guild] = Player.new(player, self).tap { @states.delete(guild) }
    end

    # Performs a search on a given query.
    # @param query [String] The item to search for.
    # @param provider [Symbol] The provider to use when searching.
    # @return [Playable] The playable object or empty data if nothing could be found.
    def search(query, provider: :automatic)
      case provider
      when :youtube_music
        Playable.new(@http.youtube_music(query), self)
      when :apple_music
        Playable.new(@http.apple_music(query), self)
      when :soundcloud
        Playable.new(@http.soundcloud(query), self)
      when :automatic
        Playable.new(resolve_search(query), self)
      when :vk_music
        Playable.new(@http.vk_music(query), self)
      when :spotify
        Playable.new(@http.spotify(query), self)
      when :youtube
        Playable.new(@http.youtube(query), self)
      when :deezer
        Playable.new(@http.deezer(query), self)
      when :url
        Playable.new(@http.search(query), self)
      end
    end

    # Decodes a bunch of encoded tracks into a playable object.
    # @param tracks [Array<String>, String] The encoded tracks to deocde.
    # @return [Playable] The playable object resulting from these tracks.
    def decode(*tracks)
      if tracks.flatten.size > 1
        Playable.new(@http.decode_tracks(tracks.flatten), self)
      else
        Playable.new(@http.decode_track(tracks.flatten.first), self)
      end
    end

    # Set whether this session is resumable.
    # @param resuming [Boolean] Whether this session is resumable.
    def resuming=(resuming)
      @http.update_session(resuming: resuming)
    end

    # Set the player timeout.
    # @param timeout [Integer] The timeout amount in seconds.
    def timeout=(timeout)
      @http.update_session(timeout: timeout)
    end

    # Get the version of this lavalink player.
    # @return [Integer] The version of this player.
    def version
      @version || @version = @http.version
    end

    # Get information about this lavalink player.
    # @return [Info] Info about this lavalink player.
    def info
      @info || @info = Info.new(@http.info)
    end

    # Ge the stats for this lavalink player.
    # @return [Stats] Stats about this lavalink player.
    def stats
      Stats.new(@http.stats)
    end

    private

    # @!visibility private
    # Internal resolver for URLs.
    def resolve_search(query)
      Playable.new(@http.search(query)).nil? ? @http.youtube(query) : @http.search(query)
    end

    # @!visibility private
    # Create a voice state hash for the given data.
    # @param token [String] The voice media server token.
    # @param endpoint [String] The voice media server endpoint.
    # @param session_id [String] The voice media sever session ID.
    # @return [Hash] The hash from the resulting voice media data.
    def to_voice(token, endpoint, session_id)
      { token: token, sessionId: session_id, endpoint: endpoint }.compact
    end

    # @!visibility private
    # Generic handler for the event dispatch event.
    def handle_event(data)
      case data["type"]
      when "TrackEndEvent"
        track_end(data)
      when "TrackStuckEvent"
        track_stuck(data)
      when "TrackStartEvent"
        track_start(data)
      when "SegmentLoaded"
        segments_loaded(data)
      when "SegmentSkipped"
        segment_skipped(data)
      when "ChaptersLoaded"
        chapters_loaded(data)
      when "ChaptersStarted"
        chapter_started(data)
      when "TrackExceptionEvent"
        track_exception(data)
      when "WebsocketClosedEvent"
        websocket_close(data)
      end
    end

    # @!visibility private
    # Internal handler for the stats event.
    def notify_stats(data)
      emit(:stats, Calliope::Events::Stats.new(data, self))
    end

    # @!visibility private
    # Internal handler for the ready event.
    def notify_ready(data)
      emit(:ready, Calliope::Events::Ready.new(data, self))
    end

    # @!visibility private
    # Internal handler for the track end event.
    def track_end(data)
      emit(__method__, Calliope::Events::TrackEnd.new(data, self))
    end

    # @!visibility private
    # Internal handler for the update event.
    def notify_update(data)
      emit(:player_state, Calliope::Events::State.new(data, self))
    end

    # @!visibility private
    # Internal handler for the track start event.
    def track_start(data)
      emit(__method__, Calliope::Events::TrackStart.new(data, self))
    end

    # @!visibility private
    # Internal handler for the track stuck event.
    def track_stuck(data)
      emit(__method__, Calliope::Events::TrackStuck.new(data, self))
    end

    # @!visibility private
    # Internal handler for the socket closed event.
    def websocket_close(data)
      emit(__method__, Calliope::Events::SocketClosed.new(data, self))
    end

    # @!visibility private
    # Internal handler for the track excepction event.
    def track_exception(data)
      emit(__method__, Calliope::Events::TrackException.new(data, self))
    end

    # @!visibility private
    # Internal handler for the segment loaded event.
    def segments_loaded(data)
      emit(__method__, Calliope::Events::SegmentsLoaded.new(data, self))
    end

    # @!visibility private
    # Internal handler for the segment skipped event.
    def segment_skipped(data)
      emit(__method__, Calliope::Events::SegmentSkipped.new(data, self))
    end

    # @!visibility private
    # Internal handler for the chapters loaded event.
    def chapters_loaded(data)
      emit(__method__, Calliope::Events::ChaptersLoaded.new(data, self))
    end

    # @!visibility private
    # Internal handler for the chapter started event.
    def chapter_started(data)
      emit(__method__, Calliope::Events::ChapterStarted.new(data, self))
    end

    # @!visibility private
    # Internal resolver for URLs.
    def url?(query)
      case query
      when %r{^(?:http(s)?://)?(?:www\.)?(?:music\.youtube\.com|m\.youtube\.com)(?:/(?:watch\?v=[\w-]+|playlist\?list=[\w-]+|track/[\w-]+))}
        true
      when %r{^(?:http(s)??://)?(?:www\.)?(music\.apple\.com/[a-z]{2}/(?:album|playlist|track)/[a-zA-Z0-9]+(?:/[a-zA-Z0-9]+)?)}
        true
      when %r{^(?:https?://)?(?:www\.)?(?:open\.spotify\.com|player\.spotify\.com)/(track|album|playlist)/[a-zA-Z0-9]{22}}
        true
      when %r{^(?:http(s)??://)?(?:www\.)?(?:(?:youtube\.com/watch\?v=)|(?:youtu.be/))(?:[a-zA-Z0-9\-_])+}
        true
      when %r{^(?:http(s)??://)?(?:www\.)?soundcloud\.com/[a-zA-Z0-9\-_]+(?:/[a-zA-Z0-9\-_]+)?}
        true
      when %r{^(?:http(s)??://)?(?:www\.)?deezer\.com/[a-z]{2}/(track|album|playlist)/\d+}
        true
      else
        false
      end
    end
  end
end
