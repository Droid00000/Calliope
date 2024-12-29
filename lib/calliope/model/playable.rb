# frozen_string_literal: true

module Calliope
  # A generic class representing playable tracks.
  class Playable
    # @return [Symbol]
    attr_reader :type

    # @return [Object]
    attr_reader :client

    # @return [Array<Tracks>]
    attr_reader :tracks

    # @return [String, nil]
    attr_reader :playlist_name

    # @return [Track, nil]
    attr_reader :selected_track

    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client)
      @client = client
      @type = payload["loadType"].to_sym

      puts payload

      @tracks = case @type
                when :playlist
                  payload["data"]["tracks"].map { |track| Track.new(track) }
                when :search
                  payload["data"].map { |track| Track.new(track) }
                when :track
                  [Track.new(payload["data"])]
                end

      return unless type == :playlist

      @playlist_name = payload["data"]["info"]["name"]
      @selected_track = payload["data"]["info"]["selectedTrack"] == -1 ? nil : @tracks[payload["info"]["SelectedTrack"]]
    end

    # Whether this is a playlist.
    # @return [Boolean]
    def playlist?
      @type == :playlist
    end

    # Whether this is a single track.
    # @return [Boolean]
    def single_track?
      @type == :track
    end

    # Whether this is a search result.
    # @return [Boolean]
    def search_result?
      @type == :search
    end

    # Play the tracks for this playable object.
    # @param guild [Integer] ID of the guild to play for.
    # @param track [Integer] Index of a specific track to play.
    # @param selected [Boolean] Whether the selected track should be played.
    def play(guild, track: nil, selected: false)
      raise ArgumentError unless @tracks && @client.player?(guild)

      if @selected_track && selected
        @client.http.modifiy_player(guild, track: @selected_track.to_h)
        return
      end

      if track && @tracks[track]
        @client.http.modify_player(guild, track: @tracks[track].to_h)
        return
      end

      @tracks.each do |track|
        @client.http.modify_player(guild, track: track.to_h)
      end
    end
  end
end
