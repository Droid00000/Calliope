# frozen_string_literal: true

# Loads all of our files for us automatically.
Dir["./calliope/**/*.rb"].each { |file| require file }

# Calliope and all of its functionality.
module Calliope
  # The current version of Calliope.
  VERSION = '1.0.0'
end
