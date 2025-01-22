# frozen_string_literal: true

module Calliope
  # Class for chapters.
  class Chapter
    # @return [String]
    attr_reader :name

    # @return [Time]
    attr_reader :duration

    # @return [Time]
    attr_reader :end_time

    # @return [Time]
    attr_reader :start_time

    # @!visibility private
    # @param payload [Hash]
    def initialize(payload)
      @name = payload["name"]
      @end_time = Time.at(payload["end"] / 1000.0)
      @start_time = Time.at(payload["start"] / 1000.0)
      @duration = Time.at(payload["duration"] / 1000.0)
    end
  end
end
