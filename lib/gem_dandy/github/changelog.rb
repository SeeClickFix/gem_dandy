# frozen_string_literal: true

require_relative '../github'

module GemDandy
  module Github
    module Changelog
      CHANGELOG_NAMES = /changelog|changes|history|news|releases/i

      def self.for(repo, tag)
        return unless repo

        begin
          files = GemDandy::Github.client.contents(repo, ref: tag)
        rescue Octokit::NotFound
          # Repo doesn't use version tags
          #
          files = GemDandy::Github.client.contents(repo)
        end

        change_log = files.find { |file| file[:name][CHANGELOG_NAMES] }
        change_log && change_log[:html_url]
      rescue Octokit::NotFound
        # Repo just flat out doesn't exist. No CHANGELOG for you
        return nil
      end
    end
  end
end
