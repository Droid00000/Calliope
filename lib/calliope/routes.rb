# frozen_string_literal: true

module Calliope
  module API
    module Endpoints
      # @param session_id [String, Integer] Voice session ID for a Discord voice connection.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def get_player(session_id, guild_id)
        request :GET, "/sessions/#{session_id}/players/#{guild_id}"
      end

      # @param session_id [String, Integer] Voice session ID for a Discord voice connection.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def modifiy_player(session_id, guild_id, replace: :undef, track: :undef, position: :undef,
                         end_time: :undef, volume: :undef, paused: :undef, filters: :undef, voice: :undef)
        data = {
          track: track,
          position: position,
          end_time: end_time,
          volume: volume,
          paused: paused,
          filters: filters,
          voice: voice
        }

        request :PATCH, "/sessions/#{session_id}/players/#{guild_id}?noReplace=#{replace}",
                body: filter_undef(data) 
      end

      # @param session_id [String, Integer] Voice session ID for a Discord voice connection.
      # @param guild_id [String, Integer] Snowflake ID that uniquely identifies a guild.
      def destory_player(session_id, guild_id)
        request :DELETE, "/sessions/#{session_id}/players/#{guild_id}"
      end

      # @param session_id [String, Integer] Voice session ID for a Discord voice connection.
      # @param resuming [Boolean] If resuming is enabled for this session or not.
      # @param timeout [Integer] The timeout in seconds.
      def update_session(session_id, guild_id, resuming: :undef, timeout: :undef)
        request :DELETE, "/sessions/#{session_id}",
                body: filter_undef({ resuming: resuming, timeout: timeout })
      end

      # @param track [String] Song URL or search term to resolve by.
      def youtube_music(track)
        request :GET, "/loadtracks?identifier=ymsearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def vk_music(track)
        request :GET, "/loadtracks?identifier=vksearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def youtube(track)
        request :GET, "/loadtracks?identifier=ytsearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def deezer(track)
        request :GET, "/loadtracks?identifier=dzsearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def spotify(track)
        request :GET, "/loadtracks?identifier=spsearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def apple_music(track)
        request :GET, "/loadtracks?identifier=amsearch:#{track}"
      end

      # @param track [String] Song URL or search term to resolve by.
      def soundcloud(track)
        request :GET, "/loadtracks?identifier=scsearch:#{track}"
      end

      # @param track [String] Base64 encoded string with the track data.
      def decode_track(track)
        request :GET, "/decodetrack?encodedTrack=#{track}"
      end

      # @param tracks [Array] Array of Base64 encoded strings with the track data.
      def decode_tracks(tracks)
        request :POST, '/decodetracks', body: tracks
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
