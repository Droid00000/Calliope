# frozen_string_literal: true

require_relative "calliope/client"

# Calliope and all its functionality.
module Calliope
  # Raised when the request body to the lavalink server was malformed.
  class BadBody < RuntimeError; end

  # Raised when our authentication is insufficent for connecting to the lavalink server.
  class Unauthorized < RuntimeError; end

  # Raised when the resource, usually a track, couldn't be found.
  class NotFound < RuntimeError; end

  # Delegates a list of methods to a particular object. This is essentially a reimplementation of ActiveSupport's
  # `#delegate`, but without the overhead provided by the rest. Used in subclasses of `Event` to delegate properties
  # on events to properties on data objects.
  # @param methods [Array<Symbol>] The methods to delegate.
  # @param hash [Hash<Symbol => Symbol>] A hash with one `:to` key and the value the method to be delegated to.
  def delegate(*methods, hash)
    methods.each do |m|
      define_method(m) do |*params|
        object = __send__(hash[:to])
        object.__send__(m, *params)
      end
    end
  end
end
