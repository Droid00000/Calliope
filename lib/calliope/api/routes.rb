# frozen_string_literal: true

module Calliope
  # The API namespace.
  module API
    # Represents REST endpoints that can be queried.
    module Routes
      # Updates or creates a new voice player in a server.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      # @param replace [Boolean] If the current track should be overriden by the new track.
      # @param track [Hash] An encoded track object.
      # @param position [Integer] The track position in milliseconds.
      # @param end_time [Integer] The track end time in milliseconds.
      # @param volume [Integer] Value between 1-1000.
      # @param paused [Boolean] Whether the player should be paused.
      # @param filters [Hash] A hash representing filters to apply.
      # @param voice [Hash] A hash representing a voice state object.
      def modify_player(guild_id, replace: false, track: :undef, position: :undef,
                        end_time: :undef, volume: :undef, paused: :undef,
                        filters: :undef, voice: :undef)
        body = {
          track: track,
          position: position,
          endTime: end_time,
          volume: volume,
          paused: paused,
          filters: filters,
          voice: voice
        }

        request :PATCH, "sessions/#{session}/players/#{guild_id}?noReplace=#{replace}",
                body: filter_undef(body)
      end

      # Remove sponsor block categories.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      # @param guild_id [Array<String>] Array of categories to delete.
      def destroy_categories(guild_id, categories)
        request :DELETE, "sessions/#{session}/players/#{guild_id}/sponsorblock/categories",
                body: categories
      end

      # Update the sponsor block categories.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      # @param guild_id [Array<String>] Array of categories to update.
      def update_categories(guild_id, categories)
        request :PUT, "sessions/#{session}/players/#{guild_id}/sponsorblock/categories",
                body: categories
      end

      # Get the enabled sponsor block categories.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def get_categories(guild_id)
        request :GET, "sessions/#{session}/players/#{guild_id}/sponsorblock/categories"
      end

      # Deletes and disconnects a voice player, stopping all further playback.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def destroy_player(guild_id)
        request :DELETE, "sessions/#{session}/players/#{guild_id}"
      end

      # @param resuming [Boolean] If resuming is enabled for this session or not.
      # @param timeout [Integer] The timeout in seconds.
      def update_session(resuming: :undef, timeout: :undef)
        request :PATCH, "sessions/#{session}",
                body: filter_undef({ resuming: resuming, timeout: timeout })
      end

      # Gets an active voice player that already exists.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def get_player(guild_id)
        request :GET, "sessions/#{session}/players/#{guild_id}"
      end

      # Perform a search using the lavasearch extension.
      # @param query [String] The term to search for.
      # @param types [String] Track, album, artist, text, etc.
      def lavasearch(query, types)
        request :GET, "loadsearch?query=#{query}&types=#{types}"
      end

      # Searches YouTube Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def youtube_music(query)
        request :GET, "loadtracks?identifier=ymsearch:#{query}"
      end

      # Searches VK Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def vk_music(query)
        request :GET, "loadtracks?identifier=vksearch:#{query}"
      end

      # Searches YouTube for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def youtube(query)
        request :GET, "loadtracks?identifier=ytsearch:#{query}"
      end

      # Searches Deezer for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def deezer(query)
        request :GET, "loadtracks?identifier=dzsearch:#{query}"
      end

      # Searches Spotify for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def spotify(query)
        request :GET, "loadtracks?identifier=spsearch:#{query}"
      end

      # Searches Apple Music for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def apple_music(query)
        request :GET, "loadtracks?identifier=amsearch:#{query}"
      end

      # Searches SoundCloud for a track.
      # @param query [String] Song URL or search term to resolve by.
      # @return [Hash] Hash containing matched tracks.
      def soundcloud(query)
        request :GET, "loadtracks?identifier=scsearch:#{query}"
      end

      # Decode a Base64 track into a track object.
      # @param track [String] Base64 encoded track.
      # @return [Hash] Hash containing the decoded track.
      def decode_track(track)
        request :GET, "decodetrack?encodedTrack=#{track}"
      end

      # Run a query on a given URL.
      # @param query [String] Song URL to resolve.
      # @return [Hash] Hash containing matched tracks.
      def search(query)
        request :GET, "loadtracks?identifier=#{query}"
      end

      # Decode multiple Base64 tracks into a track object.
      # @param tracks [Array] Base64 encoded tracks.
      # @return [Hash] Hash containing decoded tracks.
      def decode_tracks(tracks)
        request :POST, "decodetracks", body: tracks
      end

      # Get all the players for this active session.
      # @return [Array<Hash>] Array of player objects.
      def get_players
        request :GET, "sessions/#{session}/players"
      end

      # Returns information about a Lavalink player.
      def info
        request :GET, "info"
      end

      # Returns the version of a Lavalink player.
      def version
        request :GET, "version"
      end

      # Returns the version of a Lavalink player.
      def stats
        request :GET, "stats"
      end
    end
  end
end
