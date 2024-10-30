# frozen_string_literal: true

require 'calliope/client'
require 'calliope/routes'
require 'calliope/model/track'
require 'calliope/model/metadata'

# Calliope and all of its functionality.
module Calliope
  # @param milliseconds [Integer]
  def resolve_duration(milliseconds)
    Time.at(milliseconds / 1000.0).utc.strftime('%M:%S')
  end

  # @param payload [Hash]
  # @param client [Object]
  def handle_payload(payload, client)
    if payload['data'].is_a?(Array)
      Calliope::Track.new(payload['data'][0], client)
    elsif payload['data']['tracks'].key?
      payload['data']['tracks'].map { |track| Calliope::Track.new(track, client) }
    else
      Calliope::Track.new(payload['data'], client)
    end
  end
end
