# encoding: utf-8

namespace :app do
  task :register, [:name] => :environment do |t, args|
  	desc "Register Application"

  	puts "Registering Application"

  	if !args[:name]
  		fail "You need to specify a name: rake app:register[AppName]"
  	end

  	app = App.new
  	app.name = args[:name]
  	app.auth_token = Utils.build_token
  	app.save!

    puts "Finish"
    puts app.to_json
  end

  task :remove, [:name] => :environment do |t, args|
  	desc "Remove Application"

  	puts "Removing Application"

  	if !args[:name]
  		fail "You need to specify a name: rake app:remove[AppName]"
  	end

  	app = App.find_by_name(args[:name])
  	unless app.nil?
  		app.destroy
  	end

    puts "Finish"
  end

  task :refreshToken, [:name] => :environment do |t, args|
  	desc "Refresh Auth Token"

  	puts "Refreshing Auth Token"

  	if !args[:name]
  		fail "You need to specify a name: rake app:refreshToken[AppName]"
  	end

  	app = App.find_by_name(args[:name])
  	if app.nil?
  		fail "App couldn't be found"
  	end
  	app.auth_token = Utils.build_token
  	app.save!

    puts "Finish"
    puts app.to_json
  end

end

 