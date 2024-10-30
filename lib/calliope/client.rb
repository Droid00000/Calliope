# frozen_string_literal: true

require 'json'
require 'faraday'
require 'endpoints'

# Used to access Lavalink.
module Calliope
  # @!Calliope Private
  module API
    class Client
      include Endpoints

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
      def request(verb, endpoint, body: nil)
        response = @connection.send(verb.downcase.to_sym, URI::Parser.new.escape(endpoint)) do |builder|
          builder.body = body if body
        end
        handle_response(response)
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
      def filter_undef(hash)
        hash.reject { |_, v| v == :undef }
      end

      # @param response [Faraday::Response]
      def handle_response(response)
        case response.status
        when 200
          handle_payload(response.body)
        when 400
          warn 'Calliope::Errors::BadBody'
        when 401
          warn 'Calliope::Errors::Unauthorized'
        when 403
          warn 'Calliope::Errors::NoPermission'
        when 404
          warn 'Calliope::Errors::NotFound'
        when 405
          warn 'Calliope::MethodNotAllowed'
        when 429
          warn 'Calliope::RateLimit'
        end
      end
    end
  end
end
