# frozen_string_literal: true

require_relative "calliope/logger"
require_relative "calliope/client"
require_relative "calliope/version"

# Calliope and all it's functionality.
module Calliope
  # Raised when the request body to the lavalink server was malformed.
  class BadBody < RuntimeError; end

  # Raised when our authentication is insufficent for connecting to the lavalink server.
  class Unauthorized < RuntimeError; end

  # Raised when the resource, usually a track, couldn't be found.
  class NotFound < RuntimeError; end
end
