# frozen_string_literal: true

require 'octokit'

module GemDandy
  module Github
    URL = 'https://github.com'
    GITHUB_ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']

    def self.client
      @client ||= Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def self.clone_url(repo)
      "https://#{GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/#{repo}.git"
    end
  end
end
