# frozen_string_literal: true

require 'rake'
require 'fileutils'
require 'ipaddr'
require 'sentry-raven'

require_relative 'lib/depbot/github'

task :ssh_setup do
  return unless ENV['SSH_PRIVATE_KEY']

  ssh_dir = File.join(ENV['HOME'], '.ssh')
  private_key_path = File.join(ssh_dir, 'id_rsa')

  FileUtils.mkdir(ssh_dir)
  File.write(private_key_path, ENV['SSH_PRIVATE_KEY'])
  FileUtils.chmod(0600, private_key_path)
end

# Copied from https://github.com/siassaj/heroku-buildpack-git-deploy-keys/blob/develop/bin/compile#L35
#
task :github_known_hosts do
  return unless ENV['SSH_PRIVATE_KEY']

  ssh_dir = File.join(ENV['HOME'], '.ssh')
  known_hosts_path = File.join(ssh_dir, 'known_hosts')

  # Begin openssh voodoo to construct host hashes for the github ips appends
  # known github ip addresses to the github public hash, without overflowing the
  # openssh max line length.

  # Found there: https://help.github.com/articles/what-ip-addresses-does-github-use-that-i-should-whitelist/
  github_ips = IPAddr.new('192.30.252.0/22').to_range.to_a
  # Found here: https://github.com/openssh/openssh-portable/blob/0235a5fa67fcac51adb564cba69011a535f86f6b/hostfile.c#L674
  ssh_max_line_length = 8192
  template = %{github.com,%s ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==}
  ips_per_line = (ssh_max_line_length - template.bytesize) / '255.255.255.255,'.bytesize

  lines = []
  until github_ips.empty?
    lines << template % github_ips.pop(ips_per_line).join(',')
  end
  host_hash = lines.join("\n")

  File.write(known_hosts_path, host_hash)
  FileUtils.chmod(0600, known_hosts_path)
end

task update: %I[ssh_setup github_known_hosts] do
  depbot_user = ENV['DEPBOT_USER']
  repos = { 'seeclickfix/scf' => 'develop',
            'seeclickfix/depbot' => 'master' }

  repos.each do |repo_name, branch|
    open_prs = Depbot::Github.client.pull_requests(repo_name, state: 'open')

    if depbot_user && open_prs.any? { |pr| pr.user.login == depbot_user }
      puts "Open PR for '#{depbot_user}' found. " \
        "Skipping updates on '#{repo_name}' ..."
      next
    end

    system("bin/depbot #{repo_name} -b #{branch}")
  end
end
