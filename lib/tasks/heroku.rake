# frozen_string_literal: true

require 'fileutils'
require 'ipaddr'
require 'dotenv/tasks'

require_relative '../gem_dandy/github'

namespace :heroku do
  SSH_DIR = File.join(ENV['HOME'], '.ssh').to_s

  desc 'Write the SSH_PRIVATE_KEY on the remote server'
  task :write_private_key do
    abort unless ENV['SSH_PRIVATE_KEY']

    private_key_path = File.join(SSH_DIR, 'id_rsa')

    FileUtils.mkdir_p(SSH_DIR)
    File.write(private_key_path, ENV['SSH_PRIVATE_KEY'])
    FileUtils.chmod(0o600, private_key_path)
  end

  # Copied from https://github.com/siassaj/heroku-buildpack-git-deploy-keys/blob/develop/bin/compile#L35
  # with some modifications
  #
  desc 'Write github.com to the known_hosts file on the remote server'
  task :write_known_hosts do
    abort unless ENV['SSH_PRIVATE_KEY'] && ENV['GITHUB_SSH_RSA']

    known_hosts_path = File.join(SSH_DIR, 'known_hosts')

    # Found here: https://github.com/openssh/openssh-portable/blob/0235a5fa67fcac51adb564cba69011a535f86f6b/hostfile.c#L674
    ssh_max_line_length = 8192
    template = %(github.com,%s ssh-rsa #{ENV['GITHUB_SSH_RSA']})
    ips_per_line = (ssh_max_line_length - template.bytesize) /
                   '255.255.255.255,'.bytesize
    lines = []

    GemDandy::Github.client.meta.git.each do |ip_range|
      github_ips = IPAddr.new(ip_range).to_range.to_a

      until github_ips.empty?
        lines << template % github_ips.pop(ips_per_line).join(',')
      end
    end

    host_hash = lines.join("\n")

    FileUtils.mkdir_p(SSH_DIR)
    File.write(known_hosts_path, host_hash)
    FileUtils.chmod(0o600, known_hosts_path)
  end

  desc 'Update repos unless there are already open bundle update prs'
  task update: %I[dotenv write_private_key write_known_hosts] do
    REPOS_TO_UPDATE = Hash[ENV['REPOS_TO_UPDATE'].split(',').map { |s| s.split(':') }]
    GITHUB_USER = GemDandy::Github.client.user.login
    open_bundle_update_prs = ->(repo, user, title = 'Bundle Update') {
      if user
        open_prs = GemDandy::Github.client.pull_requests(repo, state: 'open')

        open_prs.any? do |pr|
          pr.user.login == GITHUB_USER && pr.title[/#{title}/]
        end
      end
    }

    REPOS_TO_UPDATE.each do |repo_name, branch|
      if open_bundle_update_prs.call(repo_name, GITHUB_USER)
        puts "Open PR for '#{GITHUB_USER}' found. " \
          "Skipping updates on '#{repo_name}' ..."
        next
      end

      system("bin/gem_dandy #{repo_name} -b #{branch}")
    end
  end
end
