# encoding: utf-8

namespace :generate do

  # How to use: 
  # bundle exec rake generate:evmethod["MethodName","ModuleName","Multiple"]
  # bundle exec rake generate:evmethod["MethodName","ModuleName","Multiple"] RAILS_ENV=production
  # For instance: bundle exec rake generate:evmethod["Lori v1.5","Lori","false"]
  task :evmethod, [:name,:module_name,:multiple] => :environment do |t, args|
  	desc "Generate new evaluation method"
  	puts "Generating new evaluation method"
    puts ""

  	if !args[:name]
  		fail "You need to specify a name for the evmethod: rake generate:evmethod[MethodName]"
  	end

    unless args[:multiple]
      multiple = false
    else
      multiple = (args[:multiple]=="true")
    end

    if !args[:module_name]
      #Try to get from name
      moduleName = args[:name].split(" ")[0].downcase.capitalize
    else
      moduleName = args[:module_name]
    end
    moduleName = "Evaluations::" + moduleName

    #Create ev method
    ev = Evmethod.new
    ev.name = args[:name]
    ev.module = moduleName
    ev.allow_multiple_evaluations = multiple
    ev.valid?

    unless ev.errors.blank?
      puts "Some error has ocurred:"
      puts ev.errors.full_messages
      puts ""
      abort("Task aborted")
    end

    if ev.save
      puts "The evaluation method was succesfully generated"
      puts ev.to_json
    else
      puts "Some error has ocurred:"
      puts ev.errors.full_messages
      puts ""
      abort("Task aborted")
    end

  end


end

 