require 'time'
require 'git'

module Depbot
  class GitRepo
    TMP_PATH = File.expand_path(File.join(__dir__, '..', '..', 'tmp')).freeze

    def initialize(repo, base_branch)
      @repo = repo
      @base_branch = base_branch
      @update_branch = "bundle-update-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}"
      @path = File.join(TMP_PATH, repo)

      @git = if Dir.exist?(path)
               Git.open(path)
             else
               Git.clone(url, repo, path: TMP_PATH)
             end

      reset_remote
    end

    attr_reader :repo, :base_branch, :update_branch, :path

    def url
      @url ||= "#{Depbot::Github::GIT_URL}:#{repo}.git"
    end

    def checkout_update_branch
      git.branch(update_branch).checkout
    end

    def delete_update_branch
      git.checkout(base_branch)
      git.branches[update_branch]&.delete
    end

    def commit_and_push(message)
      git.commit_all(message)

      git.push(git.remote.name, update_branch)
    end

    def diff_for(path)
      git.diff.find { |f| f.path == path }&.patch
    end

    private

    attr_reader :git

    def reset_remote
      git.reset_hard
      git.checkout(base_branch)
      delete_update_branch
      git.fetch
      git.reset_hard('@{u}')
    end
  end
end
