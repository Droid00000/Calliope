# frozen_string_literal: true

module Calliope
  class Metadata
    # @return [String]
    attr_reader :playback

    # @param payload [Hash]
    # @param search [object]
    def initialize(payload, search)
      if payload['data'].is_a?(Array) && !payload['data'].empty?
        @playback = payload['data'][0]['info']['uri']
      else
        @playback = payload['data']['tracks'][0]['info']['uri']
      end
    end
  end
end
