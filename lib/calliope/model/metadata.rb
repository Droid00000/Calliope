# frozen_string_literal: true

module Calliope
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
end
