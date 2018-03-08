require_relative './depbot/github'
require_relative './depbot/github/changelog'
require_relative './depbot/git_repo'
require_relative './depbot/gem_change'
require_relative './depbot/diff_parser'

module Depbot
  GITHUB_URL = 'https://github.com/SeeClickFix/depbot'.freeze
  PULL_REQUEST_FOOTER = "\n\n--\n\n" \
    "Brought to you by [depbot](#{GITHUB_URL}) - Automated Gemfile Updates\n" \
    "<sub>Feedback or Bug Reports? File a [ticket](#{GITHUB_URL}/issues).</sub>"
end
