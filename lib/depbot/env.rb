# frozen_string_literal: true

module Depbot
  # Helper methods for dealing with shell environment variables
  #
  module Env
    def self.temporarily_set(name, value)
      original_value = ENV[name]
      ENV[name] = value

      yield
    ensure
      ENV[name] = original_value
    end
  end
end
