#require 'capistrano.rb'

set :default_stage, "staging"
set :application, "lsstage"
set :domain, "184.106.113.74"
set :branch, "master"
set :deploy_via, :remote_cache

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :deploy_to, "/srv/logo-sauce"
set :repository, "git@github.com:kdave/lsstage.git"  # Your clone URL
set :scm, "git"
set :user, "root"
set :password, "logo-sauceutR4P63fV"
set :ssh_options, { :forward_agent => true }



set :server_name, "184.106.113.74"

role :app, "184.106.113.74"
role :web, "184.106.113.74"
role :db,  "184.106.113.74", :primary => true



after "deploy:update_code" do

  sudo "chown -R root:root #{deploy_to}/current/public"
  run "chmod 777 -R #{deploy_to}/current/public/"


  sudo "chown -R root:root #{deploy_to}/current/tmp"
  run "chmod 777 -R #{deploy_to}/current/tmp"

  run "cd #{current_path} && rake gems:build"

end


namespace :deploy do
  # Passenger stuff
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
