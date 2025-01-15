# frozen_string_literal: true

# Used to access the Lavalink API.
module Calliope
  # @!Calliope Private
  module API
    # The HTTP client that makes REST requests.
    class HTTP
      include Routes

      # @return [String]
      attr_accessor :session

      # @return [String]
      attr_accessor :connection

      # @param address [String] URL for connecting to the Lavalink node.
      # @param password [String] Password for connecting to the Lavalink node.
      def initialize(address, password)
        @connection = Faraday.new(address) do |builder|
          builder.request :json
          builder.response :json
          builder.headers["Authorization"] = password
          builder.headers["Content-Type"] = "application/json"
        end
      end

      # @param verb [Symbol] The HTTP verb. E.g. GET, POST, PATCH.
      # @param endpoint [String] The endpoint to make the request to.
      # @param body [Hash, nil] Optional JSON body of the HTTP request.
      # @return [Hash, Calliope::Errors, Faraday::Response]
      def request(verb, endpoint, body: nil)
        raw_request(verb.downcase, URI::Parser.new.escape(endpoint), body)
      end

      # @param verb [Symbol] The HTTP verb. E.g. GET, POST, PATCH.
      # @param endpoint [String] The endpoint to make the request to.
      # @param body [Hash, nil] Optional JSON body of the HTTP request.
      # @return [Hash, Calliope::Errors, Faraday::Response]
      def raw_request(verb, endpoint, body)
        handle_response(@connection.run_request(verb, endpoint, body, {}))
      end

      # Removes a K/V pair with an :undef value.
      # @param hash [Hash] The hash to filter from.
      # @return [Hash] The new filtered hash.
      def filter_undef(hash)
        hash&.reject { |_, v| v == :undef }
      end

      # @param response [Faraday::Response] Faraday request object.
      # @return [Hash, Calliope::Errors, Faraday::Response]
      def handle_response(response)
        case response.status
        when 200
          response.body
        when 400
          raise Calliope::BadBody
        when 401
          raise Calliope::Unauthorized
        when 404
          raise Calliope::NotFound
        else
          response
        end
      end
    end
  end
end
