# frozen_string_literal: true

module Calliope
  # Discordrb's delegate method.
  module Delegation
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
end
