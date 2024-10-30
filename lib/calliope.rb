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

  def handle_payload(payload)
  end
end
