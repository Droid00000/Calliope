# frozen_string_literal: true

module Calliope
  module API
    module Routes
      # Gets an active voice player that already exists.
      # @param session_id [String] Lavalink session ID.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def get_player(session_id, guild_id)
        request :GET, "/sessions/#{session_id}/players/#{guild_id}"
      end

      # Updates or creates a new voice player in a server.
      # @param session_id [String] Lavalink session ID.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      # @param replace [Boolean] If the current track should be overriden by the new track.
      # @param track [Hash] An encoded track object.
      # @param position [Integer] The track position in milliseconds.
      # @param end_time [Integer] The track end time in milliseconds.
      # @param volume [Integer] Value between 1-1000.
      # @param paused [Boolean] Whether the player should be paused.
      # @param filters [Hash] A hash representing filters to apply.
      # @param voice [Hash] A hash representing a voice state object.
      def modify_player(session_id, guild_id, replace: false, track: :undef,
                        position: :undef, end_time: :undef, volume: :undef,
                        paused: :undef, filters: :undef, voice: :undef,
                        state: :undef)
        body = {
          track: track,
          position: position,
          endTime: end_time,
          volume: volume,
          paused: paused,
          filters: filters,
          voice: voice,
          state: state
        }

        request :PATCH, "/sessions/#{session_id}/players/#{guild_id}?noReplace=#{replace}",
                body: filter_undef(body)
      end

      # Deletes and disconnects a voice player, stopping all further playback.
      # @param session_id [String] Lavalink session ID.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def destory_player(session_id, guild_id)
        request :DELETE, "/sessions/#{session_id}/players/#{guild_id}"
      end

      # @param session_id [String] Lavalink session ID.
      # @param resuming [Boolean] If resuming is enabled for this session or not.
      # @param timeout [Integer] The timeout in seconds.
      def update_session(session_id, resuming: :undef, timeout: :undef)
        request :DELETE, "/sessions/#{session_id}",
                body: filter_undef({ resuming: resuming, timeout: timeout })
      end

      # Perform a search using the lavasearch extension.
      # @param query [String] The term to search for.
      # @param types [String] Track, album, artist, text, etc.
      def lavasearch(query, types)
        request :GET, "/loadsearch?query=#{query}&types=#{types}"
      end

      # Searches YouTube Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def youtube_music(query)
        request :GET, "/loadtracks?identifier=ymsearch:#{query}"
      end

      # Searches VK Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def vk_music(query)
        request :GET, "/loadtracks?identifier=vksearch:#{query}"
      end

      # Searches YouTube for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def youtube(query)
        request :GET, "/loadtracks?identifier=ytsearch:#{query}"
      end

      # Searches Deezer for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def deezer(query)
        request :GET, "/loadtracks?identifier=dzsearch:#{query}"
      end

      # Searches Spotify for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def spotify(query)
        request :GET, "/loadtracks?identifier=spsearch:#{query}"
      end

      # Searches Apple Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def apple_music(query)
        request :GET, "/loadtracks?identifier=amsearch:#{query}"
      end

      # Searches SoundCloud for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def soundcloud(query)
        request :GET, "/loadtracks?identifier=scsearch:#{query}"
      end

      # Decode a Base64 track into a track object.
      # @param track [String] Base64 encoded string with the track data.
      # @return [Hash] Hash containing the decoded track.
      def decode_track(track)
        request :GET, "/decodetrack?encodedTrack=#{track}"
      end

      # Decode multiple Base64 tracks into a track object.
      # @param tracks [Array] Array of Base64 encoded strings with the track data.
      # @return [Hash] Hash containing decoded tracks.
      def decode_tracks(tracks)
        request :POST, "/decodetracks", body: tracks
      end

      # @param session_id [String, Integer] Voice session ID for a Discord voice connection.
      def get_players(session_id)
        request :GET, "/sessions/#{session_id}/players"
      end

      # Returns information about a Lavalink player.
      def info
        request :GET, "/info"
      end

      # Returns the version of a Lavalink player.
      def version
        request :GET, "/version"
      end

      # Returns the version of a Lavalink player.
      def stats
        request :GET, "/stats"
      end
    end
  end
end
