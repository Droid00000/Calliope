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
        @name = payload['data'][0].dig('info', 'title') 
        @cover = payload['data'][0].dig('info', 'artworkUrl')
        @artist = payload['data'][0].dig('info', 'author')
        @source = payload['data'][0].dig('info', 'uri')
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data'][0].dig('info', 'length'))
      elsif !payload['data']['tracks'].nil?
        @name = payload['data']['tracks'][0].dig('info', 'title')
        @cover = payload['data']['tracks'][0].dig('info', 'artworkUrl')
        @artist = payload['data']['tracks'][0].dig('info', 'author')
        @source = payload['data']['tracks'][0].dig('info', 'uri')
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data']['tracks'][0].dig('info', 'length'))
      else
        @name = payload['data'].dig('info', 'title')
        @cover = payload['data'].dig('info', 'artworkUrl')
        @artist = payload['data'].dig('info', 'author')
        @source = payload['data'].dig('info', 'uri')
        @search = search
        @playback = resolve_source unless youtube(payload)
        @duration = resolve_duration(payload['data'].dig('info', 'length'))
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

    # @return [String]
    attr_reader :connection

    # @param address [String]
    # @param password [String]
    def initialize(address, password)
      @address = address.delete_prefix('/')
      @password = password
      @connection = "#{@address}/v4"
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