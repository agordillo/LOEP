require 'bundler/capistrano' # for bundler support

set :application, "LOEP"
set :repository,  "git@github.com:loepRepository.git"

set :user, 'yourUser'
set :deploy_to, "/home/#{ user }/#{ application }"
set :use_sudo, false

set :scm, :git

default_run_options[:pty] = true

role :web, "your HTTP server"                          # Your HTTP server, Apache/etc
role :app, "your HTTP server"                          # This may be the same as your `Web` server

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# before 'deploy:assets:precompile', 'deploy:link_files'
after 'deploy:create_symlink', 'deploy:link_files'
after 'deploy:restart', 'deploy:precompile_assets'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
 # Tasks for passenger mod_rails
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
 end

 #Other tasks
  task :fix_file_permissions do
  end

  task :link_files do
    puts "LINK FILES DO"
    run "ln -s #{ shared_path}/secret_token.rb #{ release_path }/config/initializers/secret_token.rb"
    run "rm  #{ release_path }/config/initializers/session_store.rb"
    run "ln -s #{ shared_path}/secret_token.rb #{ release_path }/config/initializers/session_store.rb"
    run "ln -s #{ shared_path}/recaptcha.rb #{ release_path }/config/initializers/recaptcha.rb"
    run "ln -s #{ shared_path}/database.yml #{ release_path }/config/database.yml"
  end

  task :precompile_assets do
    run "cd #{ release_path } && bundle exec \"rake assets:precompile --trace RAILS_ENV=production\""
  end

  # task :start_sphinx do
  #   run "cd #{ current_path } && kill -9 `cat log/searchd.production.pid` || true"
  #   run "cd #{ release_path } && bundle exec \"rake ts:rebuild RAILS_ENV=production\""
  # end

  # task :fix_sphinx_file_permissions do
  #   run "/bin/chmod g+rw #{ release_path }/log/searchd*"
  #   sudo "/bin/chgrp www-data #{ release_path }/log/searchd*"
  # end

end