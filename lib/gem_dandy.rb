# frozen_string_literal: true

require_relative './gem_dandy/version'
require_relative './gem_dandy/github'
require_relative './gem_dandy/github/changelog'
require_relative './gem_dandy/git_repo'
require_relative './gem_dandy/gem_change'
require_relative './gem_dandy/diff_parser'
require_relative './gem_dandy/env'
require_relative './gem_dandy/bundler'

module GemDandy
  GITHUB_URL = 'https://github.com/SeeClickFix/gem_dandy'
  PULL_REQUEST_FOOTER = <<~HEREDOC


    --


    Brought to you by [gem_dandy](#{GITHUB_URL}) - Automated Gemfile Updates
    <sub>Feedback or Bug Reports? File a [ticket](#{GITHUB_URL}/issues).</sub>
  HEREDOC
end
