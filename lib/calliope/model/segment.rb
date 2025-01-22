# frozen_string_literal: true

module Calliope
  # Class for segments.
  class Segment
    # @return [Symbol]
    attr_reader :category

    # @return [Time]
    attr_reader :end_time

    # @return [Time]
    attr_reader :start_time

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @category = payload["category"].to_sym
      @end_time = Time.at(payload["end"] / 1000.0)
      @start_time = Time.at(payload["start"] / 1000.0)
    end
  end
end
