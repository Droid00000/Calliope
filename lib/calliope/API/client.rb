# frozen_string_literal: true

require 'errors'
require 'faraday'
require 'API/routes'

# Used to access the Lavaplayer API.
module Calliope
  # @!Calliope Private
  module API
    class Client
      include Routes

      # @return [String]
      attr_reader :address

      # @return [String]
      attr_reader :password

      # @return [String]
      attr_reader :connection

      # @param address [String]
      # @param password [String]
      def initialize(address, password)
        @address = "#{address.delete_prefix('/')}/v4"
        @password = password
        @connection = Faraday.new(@address) do |builder|
          builder.headers['Authorization'] = @password
          builder.response :json
        end
      end

      # @param verb [Symbol]
      # @param endpoint [String]
      # @param body [Hash]
      # @return [Hash, Calliope::Errors]
      def request(verb, endpoint, body: nil)
        raw_request(verb.downcase, URI::Parser.new.escape(endpoint), body)
      end

      # @param verb [Symbol]
      # @param endpoint [String]
      # @param body [Hash]
      # @return [Hash, Calliope::Errors]
      def raw_request(verb, endpoint, body: nil)
        handle_response(@connection.run_request(verb, endpoint, body, nil))
      end

      # @param song [String] Song URL or search term to resolve by.
      def resolve(track)
        case track
        when %r{^(?:https?://)?(?:www\.)?(?:youtu\.be|youtube\.com)}
          youtube(track)
        when %r{^https?://(www\.)?music\.youtube\.com}i
          youtube(track)
        when %r{(?i)https?://open\.spotify\.com}
          youtube(track)
        when %r{(?i)https?://music\.apple\.com}
          youtube(track)
        else
          spotify(track)
        end
      end

      # @param hash [Hash<Object, Object>]
      # @return [Hash]
      def filter_undef(hash)
        hash.reject { |_, v| v == :undef }
      end

      # @param payload [Hash]
      # @param client [Object]
      def handle_tracks(payload, client)
        if payload['data'].is_a?(Array)
          Calliope::Track.new(payload['data'][0], client)
        elsif !payload.dig('data', 'tracks').nil?
          payload['data']['tracks'].map { |track| Calliope::Track.new(track, self) }
        else
          Calliope::Track.new(payload['data'], client)
        end
      end

      # @param response [Faraday::Response]
      # @return [Hash, Calliope::Errors]
      def handle_response(response)
        case response.status
        when 200
          response.body
        when 204
          nil
        when 400
          raise Calliope::Errors::BadBody
        when 401
          raise Calliope::Errors::Unauthorized
        when 404
          raise Calliope::Errors::NotFound
        else
          response
        end
      end
    end
  end
end
