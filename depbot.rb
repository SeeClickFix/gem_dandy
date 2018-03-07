require "bundler/setup"

require "octokit"
require "dotenv"
require "fileutils"
require "git"
require "logger"
require "date"
require "httparty"

require "pry"

Dotenv.load

DEFAULT_BRANCH_HACK = "develop"

LOGGER = Logger.new(STDOUT)
GITHUB_URL = "https://github.com"
REPO = ENV["GITHUB_REPO"]
GITHUB_REPO_URL = "#{GITHUB_URL}/#{REPO}"
TMP_FOLDER = File.join(__dir__, "tmp")
BRANCH_NAME = "bundle-update-#{Date.today.strftime("%Y-%m-%d")}"
DIFF_REGEX = %r{^(?<operation>[-+])\s+(?<name>[\w-]+)[^\d.]+(?<version>[\d.]+)}

client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
folder = File.join(TMP_FOLDER, REPO)

FileUtils.mkdir_p(folder)

git = if Dir.exists?(File.join(folder, ".git"))
  g = Git.open(folder, log: LOGGER)
  g.reset_hard
  g.checkout(DEFAULT_BRANCH_HACK)
  g.fetch
  g.reset_hard("@{u}")
  g
else
  LOGGER.info "Cloning #{GITHUB_REPO_URL} ..."
  Git.clone(GITHUB_REPO_URL, REPO, path: TMP_FOLDER, log: LOGGER)
end

git.branch(BRANCH_NAME)
git.branch(BRANCH_NAME).checkout

FileUtils.chdir folder do
  system("BUNDLE_GEMFILE=#{folder}/Gemfile bundle update")
end

if git.status.changed.none?
  abort "No updates today"
end

diff = git.diff.to_a.first.patch

changes = diff.split("\n")
changes = changes.reject {|c| c[/\A(diff|index|\+\+\+|---|@@|\s)/] }

old, new = changes.
  map { |c| DIFF_REGEX.match(c)&.named_captures }.
  compact.
  partition {|c| c["operation"] == "-" }

GemUpdate = Struct.new(:name, :old_version, :new_version, :url)

get_gem_url = ->(name) {
  response = HTTParty.get("https://rubygems.org/api/v1/gems/#{name}.json")

  response["source_code_uri"] || response["homepage_uri"]
}

get_change_url = -> (url) {
  return nil if url.nil? || url == "" || !url[/github/]

  repo_name = /github.com\/([\w-]+\/[\w-]+)/.match(url).captures.first

  files = client.contents(repo_name)

  change_log = files.find {|file| file[:name][/changelog|changes|history|news|releases/i] }

  change_log && change_log[:html_url]
}

changed_gems = old.uniq.map do |changes|
  name = changes["name"]

  new_version = new.find {|new_change| new_change["name"] == name }["version"]

  url = get_gem_url.call(name)

  GemUpdate.new(name, changes["version"], new_version, url)
end

GemUpdateFormatter = ->(gem) {
  if gem.url && gem.url != ""
    markdown = "[#{gem.name}](#{gem.url}), " \
      "[#{gem.old_version}...#{gem.new_version}](#{gem.url}/compare/v#{gem.old_version}...v#{gem.new_version})"

    if change_log = get_change_url.call(gem.url)
      markdown += " ([CHANGELOG](#{change_log}))"
    end

    markdown
  else
    "#{gem.name}, #{gem.old_version}...#{gem.new_version}"
  end
}

### Commit ###

commit_message = "Bundle Update on #{Date.today.strftime("%Y-%m-%d")}"

git.commit_all(commit_message)

git.push(git.remote.name, BRANCH_NAME)

### Pull Request ###

pull_request_message = "**Updated RubyGems:**\n\n"
pull_request_message += changed_gems.map do |gem|
  "- #{GemUpdateFormatter.call(gem)}"
end.join("\n")
pull_request_message += "\n\n--\n\n"
pull_request_message += "Brought to you by [jordanbyron](https://jordanbyron.com) - Automated Gemfile Updates\n" \
  "<sub>Feedback or Bug Reports? Talk to @tneems</sub>"

pull_request = client.create_pull_request(REPO, DEFAULT_BRANCH_HACK, BRANCH_NAME,
  commit_message, pull_request_message)

puts "Pull Request Created: #{pull_request[:html_url]}"
