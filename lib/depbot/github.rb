require "octokit"

module Depbot
  module Github
    URL = 'https://github.com'.freeze

    def self.client
      @client ||= Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
    end
  end
end
