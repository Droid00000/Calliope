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

      if type == :playlist
        @playlist_name = payload["data"]["info"]["name"]
        @selected_track = payload["data"]["info"]["selectedTrack"] == -1 ? nil : @tracks[payload["info"]["SelectedTrack"]]
      else
        @playlist_name = nil
        @selected_track = nil
      end

      if tracks && tracks.count == 1 && @selected_track
        [:isrc, :cover, :artist, :source, :encoded, :position, :duration].each do |method|
          instance_variable_set("@#{method}".to_sym, @selected_track.send(method))
        end
      end

      if tracks && tracks.count == 1 && selected_track.nil?
        [:isrc, :cover, :artist, :source, :encoded, :position, :duration].each do |method|
          instance_variable_set("@#{method}".to_sym, @tracks.first.send(method))
        end
      end
    end

    def name
      if tracks && tracks.count == 1 && selected_track.nil?
        @tracks.first.name
        return
      end

      if @tracks && @tracks.count == 1 && @selected_track
        @selected_track.name
        return
      end

      if playlist? && @selected_track.nil?
        @playlist_name
        return
      end
    end

    def proccess_length(milliseconds)
      Time.at(milliseconds / 1000.0).utc.strftime('%M:%S')
    end

    def strftime
      if tracks && tracks.count == 1 && selected_track.nil?
        proccess_length(@tracks.first.duration)
        return
      end

      if @tracks && @tracks.count == 1 && @selected_track
        proccess_length(@selected_track.duration)
        return
      end

      if @type == :playlist? && @selected_track.nil?
        proccess_length(@playlist.sum(:duration))
        return
      end
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

    # This is a sneaky way to delegation without actually using it.
    def method_missing(method_name, *args, &block)
      if instance_variable_defined?("@#{method_name}".to_sym)
        instance_variable_get("@#{method_name}".to_sym)
      end
    end

    # Play the tracks for this playable object.
    # @param guild [Integer] ID of the guild to play for.
    # @param track [Integer] Index of a specific track to play.
    # @param selected [Boolean] Whether the selected track should be played.
    def play(guild, track: nil, first: true, selected: false)
      raise ArgumentError unless @tracks

      if @selected_track && selected
        @client.http.modifiy_player(guild, track: @selected_track.to_h)
        return
      end

      if track && @tracks[track]
        @client.http.modify_player(guild, track: @tracks[track].to_h)
        return
      end

      if search_result? && first
        @client.http.modify_player(guild, track: @tracks.first.to_h)
        return
      end

      @tracks.each do |track|
        @client.http.modify_player(guild, track: track.to_h)
      end
    end
  end
end
