# frozen_string_literal: true

module Calliope
  # A generic class representing playable data.
  class Playable
    # @return [Symbol]
    attr_reader :type

    # @return [Array<Tracks>]
    attr_reader :tracks

    # @return [Object]
    attr_reader :client

    # @return [String, nil]
    attr_reader :playlist_name

    # @return [Integer, nil]
    attr_reader :selected_track

    # @param payload [Hash]
    # @param type [Symbol]
    # @param client [Object]
    def initialize(payload, type, client)
      @type = type
      @client = client
      @tracks = resolve_tracks(payload)

      return unless type == :playlist

      @playlist_name = payload["data"]["info"]["name"]
      @selected_track = payload["data"]["info"]["selectedTrack"] == -1 ? nil : payload["info"]["SelectedTrack"]
    end

    # Whether this is a playlist.
    # @return [Boolean]
    def playlist?
      @type == :playlist
    end

    # Whether this is a single track.
    # @return [Boolean]
    def track?
      @type == :single
    end

    alias single_track track?

    # Whether this is a search result.
    # @return [Boolean]
    def search?
      @type == search
    end

    alias search_result? search?

    def play_all(guild)
      return unless @client.player?(guild)

      @tracks.each do |track|
        @client.http.modify_player(@client.session, guild.to_s, track: track.to_p)
      end
    end

    def play_selected(guild)
      return unless @client.player?(guild) && @selected_track

      @client.http.modifiy_player(@client.session, guild, track: @tracks[@selected_track].to_p)
    end

    private

    # Converts the track data into track objects.
    def resolve_tracks(payload)
      case type
      when :playlist
        payload["data"]["tracks"].map { |track| Track.new(track) }
      when :search
        payload["data"].map { |track| Track.new(track) }
      when :single
        [Track.new(payload["data"])]
      end
    end
  end
end
