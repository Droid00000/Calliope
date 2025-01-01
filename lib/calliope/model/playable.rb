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
    def initialize(payload, client)
      @client = client
      @type = payload["loadType"]&.to_sym || :decode

      @tracks = case @type
                when :playlist
                  payload["data"]["tracks"].map { |track| Track.new(track) }
                when :search
                  payload["data"].map { |track| Track.new(track) }
                when :decode
                  payload.map { |track| Track.new(track) }
                when :track
                  [Track.new(payload["data"])]
                end

      if type == :playlist
        @playlist_name = payload["data"]["info"]["name"]
        @selected_track = payload["data"]["info"]["selectedTrack"] == -1 ? nil : @tracks[payload["info"]["SelectedTrack"]]
      end

      if @tracks && (type == :search || type == :track || type == :decode || (type == :playlist && selected_track.nil?))
        %i[isrc cover artist source encoded position duration].each do |method|
          instance_variable_set(:"@#{method}", @tracks.first.send(method))
        end
      end

      return unless @selected_track

      %i[isrc cover artist source encoded position duration].each do |method|
        instance_variable_set(:"@#{method}", @selected_track.send(method))
      end
    end

    # Return the duration formatted as: M:S or H:M:S.
    # @return [String] The formatted time string.
    def strftime
      if @tracks && (@type == :search || @type == :track || (@type == :playlist && @tracks.count == 1))
        return Time.at(@tracks.first.duration / 1000.0).utc.strftime("%M:%S")
      end

      if @tracks && @type == :playlist && @selected_track
        return Time.at(@selected_track.duration / 1000.0).utc.strftime("%M:%S")
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
      @client.players[guild]&.playing? ? "Queued" : "Now Playing"
    end

    # Queue the tracks for this playable object.
    # @param guild [Integer] ID of the guild to queue for.
    # @param track [Integer] Index of a specific track to queue.
    # @param selected [Boolean] Whether the selected track should be queued.
    # @param first [Boolean] Whether the first track should be played if this is a search result. Defaults to true.
    def produce_queue(guild, track: nil, selected: false, first: true)
      raise ArgumentError unless @tracks && @client.players[guild]

      if @selected_track && selected
        @client.players[guild].queue = [@selected_track.to_h]
        return
      end

      if track && @tracks[track]
        @client.players[guild].queue = [@tracks[track].to_h]
        return
      end

      if search_result? && first
        @client.players[guild].queue = [@tracks.first.to_h]
        return
      end

      @client.players[guild].queue = @tracks.map(&:to_h)
    end

    # Play the tracks for this playable object.
    # @param guild [Integer] ID of the guild to play for.
    # @param track [Integer] Index of a specific track to play.
    # @param selected [Boolean] Whether the selected track should be played.
    # @param first [Boolean] Whether the first track should be played if this is a search result. Defaults to true.
    def play(guild, track: nil, selected: false, first: true)
      raise ArgumentError unless @tracks && @client.players[guild]

      if @selected_track && selected
        @client.http.modifiy_player(guild, track: @selected_track.to_h)
        return
      end

      if track && @tracks[track]
        @client.http.modify_player(guild, track: @tracks[track].to_h)
        return
      end

      if search? && first
        @client.http.modify_player(guild, track: @tracks.first.to_h)
        return
      end

      @tracks.each do |track|
        @client.http.modify_player(guild, track: track.to_h)
      end
    end
  end
end
