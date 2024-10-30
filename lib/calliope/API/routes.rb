# frozen_string_literal: true

module Calliope
  module API
    module Endpoints
      # @param track [String] Song URL or search term to resolve by.
      def youtube_music(track)
        response = run_request("ymsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def vk_music(track)
        response = run_request("vksearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def youtube(track)
        response = run_request("ytsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def deezer(track)
        response = run_request("dzsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def spotify(track)
        response = run_request("spsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def apple_music(track)
        response = run_request("spsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def soundcloud(track)
        response = run_request("scsearch:#{track}")
        Calliope::Song.new(response, self)
      end

      # @param track [String] Song URL or search term to resolve by.
      def source(track)
        response = run_request("ytsearch:#{track}")
        Calliope::Metadata.new(response, self)
      end
    end
  end
end
