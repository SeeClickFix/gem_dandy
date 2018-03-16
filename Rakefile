require 'rake'
require 'fileutils'

task :ssh_setup do
  return unless ENV['SSH_PRIVATE_KEY']

  ssh_dir = File.join(ENV['HOME'], '.ssh')
  private_key_path = File.join(ssh_dir, 'id_rsa')

  FileUtils.mkdir(ssh_dir)
  File.write(private_key_path, ENV['SSH_PRIVATE_KEY'])
  FileUtils.chmod(0600, private_key_path)
end

task update: [:ssh_setup] do
  repos = { 'seeclickfix/scf' => 'develop',
            'seeclickfix/depbot' => 'master' }

  repos.each do |repo_name, branch|
    system("bin/depbot #{repo_name} -b #{branch}")
  end
end
