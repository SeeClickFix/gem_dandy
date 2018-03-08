require_relative "../github"

module Depbot
  module Github
    module Changelog
      CHANGELOG_NAMES = /changelog|changes|history|news|releases/i

      def self.for(repo, tag)
        return unless repo

        begin
          files = Depbot::Github.client.contents(repo, ref: tag)
        rescue Octokit::NotFound
          # Repo doesn't use version tags
          #
          files = Depbot::Github.client.contents(repo)
        end

        change_log = files.find { |file| file[:name][CHANGELOG_NAMES] }
        change_log && change_log[:html_url]
      end
    end
  end
end
