require 'rake'

task :update do
  repos = { 'seeclickfix/scf' => 'develop',
            'seeclickfix/depbot' => 'master' }

  repos.each do |repo_name, branch|
    system("bin/depbot #{repo_name} -b #{branch}")
  end
end
