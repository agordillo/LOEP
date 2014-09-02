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
  		fail "You need to specify a name for the evmethod: bundle exec rake generate:evmethod[\"MethodName\",\"ModuleName\",\"Multiple\"]"
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


  # How to use: 
  # bundle exec rake generate:metric["MetricName","ModuleName","EvMethodNames"]
  # bundle exec rake generate:metric["MetricName","ModuleName","EvMethodNames"] RAILS_ENV=production
  # For instance: bundle exec rake generate:metric["LOEM Arithmetic Mean","LOEMAM","LOEM"]
  task :metric, [:name,:module_name,:evmethodslist] => :environment do |t, args|
    desc "Generate new metric"
    puts "Generating new metric"
    puts ""

    if !args[:name] or !args[:module_name] or !args[:evmethodslist]
      fail "You need to specify a name, module name and evmethods for the metric: bundle exec rake generate:metric[\"MetricName\",\"ModuleName\",\"EvMethodNames\"]"
    end

    moduleName = "Metrics::" + args[:module_name]

    #Create metric
    m = moduleName.constantize.new
    m.name = args[:name]
    m.evmethods.push(Evmethod.find_all_by_name(args[:evmethodslist].split("&&").map{|s| s.strip}))
    m.valid?

    unless m.errors.blank?
      puts "Some error has ocurred:"
      puts m.errors.full_messages
      puts ""
      abort("Task aborted")
    end

    if m.save
      puts "The metric was succesfully generated"
      puts m.to_json
    else
      puts "Some error has ocurred:"
      puts m.errors.full_messages
      puts ""
      abort("Task aborted")
    end

  end


end

 