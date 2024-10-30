# frozen_string_literal: true

require 'json'
require 'faraday'
require 'endpoints'

# Used to access Lavaplayer.
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
          handle_payload(JSON.parse(response.body))
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
end
