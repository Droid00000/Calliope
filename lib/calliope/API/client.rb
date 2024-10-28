# frozen_string_literal: true

require 'json'
require 'faraday'

# Used to access Lavaplayer.
module Calliope
  # @!Calliope Private
  class Song
    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :cover

    # @return [String]
    attr_reader :artist

    # @return [String]
    attr_reader :source

    # @return [Object]
    attr_reader :search

    # @return [String]
    attr_reader :playback

    # @return [String]
    attr_reader :duration

    # @param payload [Hash]
    # @param search [object]
    def initialize(payload, search)
      puts payload
      if payload['data'].is_a?(Array) && !payload['data'].empty?
        @name = payload['data'][0].dig('info', 'title') || 'Name Unknown'
        @cover = payload['data'][0].dig('info', 'artworkUrl') || 'Cover Unknown'
        @artist = payload['data'][0].dig('info', 'author') || 'Artist Unknown'
        @source = payload['data'][0].dig('info', 'uri') || 'URL Unknown'
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data'][0].dig('info', 'length')) || 'Duration Unknown'
      elsif !payload['data']['tracks'].nil?
        @name = payload['data']['tracks'][0].dig('info', 'title') || 'Name Unknown'
        @cover = payload['data']['tracks'][0].dig('info', 'artworkUrl') || 'Cover Unknown'
        @artist = payload['data']['tracks'][0].dig('info', 'author') || 'Artist Unknown'
        @source = payload['data']['tracks'][0].dig('info', 'uri') || 'URL Unknown'
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data']['tracks'][0].dig('info', 'length')) || 'Duration Unknown'
      else
        @name = payload['data'].dig('info', 'title') || 'Name Unknown'
        @cover = payload['data'].dig('info', 'artworkUrl') || 'Cover Unknown'
        @artist = payload['data'].dig('info', 'author') || 'Artist Unknown'
        @source = payload['data'].dig('info', 'uri') || 'URL Unknown'
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data'].dig('info', 'length')) || 'Duration Unknown'
      end
    end

    # @param milliseconds [Integer]
    def resolve_duration(milliseconds)
      Time.at(milliseconds / 1000.0).utc.strftime('%M:%S')
    end

    # @return [String] 
    def resolve_source
      @search.source("#{@name} #{@artist}").playback
    end

    # @param payload [Hash]
    def youtube(payload)
      payload['data'][0].dig('info', 'sourceName') == 'youtube' if payload['data'].is_a?(Array)
      payload['data']['tracks'][0].dig('info', 'sourceName') == 'youtube' if payload['data'].is_a?(Hash) && payload['data']['tracks']
      payload['data'].dig('info', 'sourceName') == 'youtube' if payload['data'].is_a?(Hash) && payload['data']['tracks'].nil?
    end
  end

  class Metadata
    # @return [String]
    attr_reader :playback

    # @param payload [Hash]
    # @param search [object]
    def initialize(payload, search)
      if payload['data'].is_a?(Array) && !payload['data'].empty?
        @playback = payload['data'][0].dig('info', 'uri')
      else
        @playback = payload['data']['tracks'][0].dig('info', 'uri')
      end
    end
  end

  class Client
    # @return [String]
    attr_reader :address

    # @return [String]
    attr_reader :password

    # @param address [String]
    # @param password [String]
    def initialize(address, password)
      @address = address
      @password = password
    end

    # @param query [String]
    def run_request(query)
      response = Faraday.get("#{@address}/v4/loadtracks?identifier=#{query}") do |builder|
        builder.headers['Authorization'] = @password
      end
      handle_response(response)
    end

    # @param song [String] Song URL or search term to resolve by.
    def resolve(track)
      case track
      when %r{^(?:https?://)?(?:www\.)?(?:youtu\.be|youtube\.com)}
        search(track)
      when %r{(?i)https?://open\.spotify\.com}
        search(track)
      when %r{(?i)https?://music\.apple\.com}
        search(track)
      else
        search(track)
      end
    end

    # @param track [String] Song URL or search term to resolve by.
    def vk_music(track)
      response = run_request("vksearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def youtube(track)
      response = run_request("ytsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def deezer(track)
      response = run_request("dzsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def deezer(track)
      response = run_request("ymsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def spotify(track)
      response = run_request("spsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def apple_music(track)
      response = run_request("spsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def soundcloud(track)
      response = run_request("scsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Song.new(response, self)
    end

    # @param track [String] Song URL or search term to resolve by.
    def source(track)
      response = run_request("ytsearch:#{URI.encode_www_form_component(track)}")
      Calliope::Metadata.new(response, self)
    end

    # @param response [Faraday::Response]
    def handle_response(response)
      case response.status
      when 200
        JSON.parse(response.body)
      when 400
        raise 'Calliope::Errors::BadBody'
      when 401
        raise 'Calliope::Errors::Unauthorized'
      when 403
        raise 'Calliope::Errors::NoPermission'
      when 404
        raise 'Calliope::Errors::NotFound'
      when 405
        raise 'Calliope::MethodNotAllowed'
      when 429
        raise 'Calliope::RateLimit'
      end
    end
  end
end