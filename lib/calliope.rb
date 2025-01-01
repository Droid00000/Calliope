# frozen_string_literal: true

require_relative "calliope/client"

# Calliope and all its functionality.
module Calliope
  # The current version of calliope.
  VERSION = "0.1.0"

  # Raised when the request body to the lavalink server was malformed.
  class BadBody < RuntimeError; end

  # Raised when our authentication is insufficent for connecting to the lavalink server.
  class Unauthorized < RuntimeError; end

  # Raised when the resource, usually a track, couldn't be found.
  class NotFound < RuntimeError; end
end
