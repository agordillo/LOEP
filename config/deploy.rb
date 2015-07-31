# Call this script with the following syntax:
# bundle exec cap deploy DEPLOY=environmentName
# Where environmentName is the name of the xml file (config/deploy/environmentName.xml) which defines the deployment.

require 'yaml'
require 'bundler/capistrano'

deployEnvironment = ENV['DEPLOY']

begin
  config = YAML.load_file(File.expand_path('../deploy/' + deployEnvironment + '.yml', __FILE__))
  puts config["message"]
  repository = config["repository"]
  server_url = config["server_url"]
  username = config["username"]
  keys = config["keys"]
  branch = config["branch"] || "master"
  deploy_to = config["deploy_to"] || "/home/#{ user }/#{ application }"
rescue Exception => e
  #puts e.message
  unless deployEnvironment.nil?
    puts "Sorry, the file config/deploy/" + deployEnvironment + '.yml does not exist.'
  else
    puts "No environment was specified. Please call this script using the following syntax: 'bundle exec cap deploy DEPLOY=environmentName'."
  end
  exit
end

set :scm, :git

set :application, "LOEP"
set :repository,  repository

set :user, username
set :deploy_to, deploy_to
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
if keys
  ssh_options[:keys] = keys
end

role :web, server_url # Your HTTP server, Apache/etc
role :app, server_url # This may be the same as your `Web` server
role :db,  server_url, :primary => true # This is where Rails migrations will run


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

after 'deploy:update_code', 'deploy:link_files'
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
    puts "Link Files do..."
    run "ln -s #{ shared_path}/database.yml #{ release_path }/config/database.yml"
    run "ln -s #{ shared_path}/application_config.yml #{ release_path }/config/application_config.yml"   
  end

  task :precompile_assets do
    run "cd #{ release_path } && bundle exec \"rake assets:precompile --trace RAILS_ENV=production\""
  end

end