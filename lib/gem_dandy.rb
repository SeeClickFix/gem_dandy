# frozen_string_literal: true

require_relative './gem_dandy/version'
require_relative './gem_dandy/github'
require_relative './gem_dandy/github/changelog'
require_relative './gem_dandy/git_repo'
require_relative './gem_dandy/gem_change'
require_relative './gem_dandy/diff_parser'
require_relative './gem_dandy/env'

module GemDandy
  GITHUB_URL = 'https://github.com/SeeClickFix/gem_dandy'
  PULL_REQUEST_FOOTER = "\n\n--\n\n" \
    "Brought to you by [gem_dandy](#{GITHUB_URL}) - Automated Gemfile Updates\n" \
    "<sub>Feedback or Bug Reports? File a [ticket](#{GITHUB_URL}/issues).</sub>"
end
