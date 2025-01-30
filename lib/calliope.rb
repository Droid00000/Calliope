# frozen_string_literal: true

require "calliope/client"

# Calliope and all its functionality.
module Calliope
  # Raised when the request body to the lavalink server contains an error.
  class BadBody < RuntimeError; end

  # Raised when incorrect credentials were provided to the lavalink server.
  class Unauthorized < RuntimeError; end

  # Raised when the requested resource path doesn't exist or can't be found.
  class NotFound < RuntimeError; end
end
