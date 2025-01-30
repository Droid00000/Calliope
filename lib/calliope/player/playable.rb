# frozen_string_literal: true

module Calliope
  # A generic class representing playable results.
  class Playable
    # @return [Symbol]
    attr_reader :type

    # @return [Client]
    attr_reader :client

    # @return [Array<Tracks>]
    attr_reader :tracks

    # @return [String, nil]
    attr_reader :playlist_name

    # @return [Track, nil]
    attr_reader :selected_track

    # @!visibility private
    # @param payload [Hash]
    # @param client [Object]
    def initialize(payload, client = nil)
      @client = client
      @type = payload["loadType"]&.to_sym || :decode

      @tracks = case @type
                when :playlist
                  payload["data"]["tracks"].map { |track| Track.new(track) }
                when :decode
                  [payload].flatten.map { |track| Track.new(track) }
                when :search
                  payload["data"].map { |track| Track.new(track) }
                when :track
                  [Track.new(payload["data"])]
                end

      if type == :playlist
        @playlist_name = payload["data"]["info"]["name"]
        @selected_track = if payload["data"]["info"]["selectedTrack"] == -1
                            nil
                          else
                            @tracks[payload["data"]["info"]["SelectedTrack"]]
                          end
      end

      if @tracks && (type == :search || type == :track || type == :decode || (type == :playlist && selected_track.nil?))
        %i[isrc cover artist source encoded position duration].each do |method|
          instance_variable_set(:"@#{method}", @tracks.first.send(method))
        end
      end

      if @tracks && (type == :playlist && selected_track.nil?) && !payload["data"]["pluginInfo"].empty?
        @playlist_type = payload["data"]["pluginInfo"]["totalTracks"]&.to_sym
        @total_tracks = payload["data"]["pluginInfo"]["totalTracks"] || nil
        @cover = payload["data"]["pluginInfo"]["artworkUrl"] || @cover
        @artist = payload["data"]["pluginInfo"]["author"] || @artist
        @source = payload["data"]["pluginInfo"]["url"] || @source
      end

      if @tracks && type == :track && !payload["data"]["pluginInfo"].empty?
        @album_name = payload["data"]["pluginInfo"]["albumName"]
        @album_cover = payload["data"]["pluginInfo"]["albumArtUrl"]
        @artist_url = payload["data"]["pluginInfo"]["artistUrl"]
        @artist_cover = payload["data"]["pluginInfo"]["artistArtworkUrl"]
        @preview_url = payload["data"]["pluginInfo"]["previewUrl"]
        @is_preview = payload["data"]["pluginInfo"]["isPreview"]
      end

      return unless @selected_track

      %i[isrc cover artist source encoded position duration].each do |method|
        instance_variable_set(:"@#{method}", @selected_track.send(method))
      end
    end

    # Return the duration formatted as: M:S or H:M:S.
    # @return [String] The formatted time string.
    def strftime
      if @tracks && (@type == :search || @type == :track || @tracks.size == 1 || (@type == :playlist && @tracks.count == 1))
        return @tracks.first.strftime
      end

      if @tracks && @type == :playlist && @selected_track
        return @selected_track.strftime
      end

      return unless (@type == :playlist && @selected_track.nil?) || @type == :decode

      if @tracks.map(&:duration).sum / 1000.0 >= 3600
        return Time.at(@tracks.map(&:duration).sum / 1000.0).utc.strftime("%H:%M:%S")
      end

      Time.at(@tracks.map(&:duration).sum / 1000.0).utc.strftime("%M:%S")
    end

    # Gets the name of a track.
    # @return [String] The name of the track.
    def name
      if @type == :playlist && @selected_track.nil?
        return @playlist_name
      end

      if @tracks && @type == :track
        return @tracks.first.name
      end

      if @tracks && @selected_track
        return @selected_track.name
      end

      return unless @type == :search || @type == :decode

      @tracks.first.name
    end

    # @!method search?
    # @return [Boolean] whether this is a search result.
    # @!method decode?
    # @return [Boolean] whether these are decoded tracks.
    # @!method playlist?
    # @return [Boolean] whether this is a playlist.
    # @!method track?
    # @return [Boolean] whether this is a track.
    %i[playlist track search decode].each do |type|
      define_method("#{type}?") do
        @type == type
      end
    end

    # @!visibility private
    # @note For internal use only.
    # This is a sneaky way to use delegation without actually using it.
    def method_missing(method_name, *_args)
      return unless instance_variable_defined?(:"@#{method_name}")

      instance_variable_get(:"@#{method_name}")
    end

    # Utility method to get the status of a player.
    # @param guild [Integer] The ID of the guild playing.
    # @return [String] If the player is currently playing or it's operating in queue mode.
    def status(guild)
      @client.players[guild]&.status || "Now Playing"
    end

    # Utility method that overrides nil by default to be more useful.
    # @return [Boolean] If this is an empty/nullable playable object.
    def nil?
      @tracks.nil?
    end

    # Queue the tracks for this playable object.
    # @param guild [Integer] ID of the guild to queue for.
    # @param track [Integer] Index of a specific track to queue.
    # @param selected [Boolean] Whether the selected track should be queued.
    # @param first [Boolean] Whether the first track should be played if this is a search result. Defaults to true.
    def queue(guild, track: nil, selected: false, first: true)
      raise ArgumentError unless @tracks && @client.players[guild]

      if @selected_track && selected
        @client.players[guild].queue.add(@selected_track)
        return
      end

      if track && @tracks[track]
        @client.players[guild].queue.add(@tracks[track])
        return
      end

      if search? && first
        @client.players[guild].queue.add(@tracks.first)
        return
      end

      @client.players[guild].queue.add(@tracks)
    end
  end
end
