# encoding: utf-8

namespace :generate do

  # How to use: 
  # bundle exec rake generate:token
  # bundle exec rake generate:token RAILS_ENV=production
  task :token, [:length] => :environment do |t, args|
    if args[:length]
      length = args[:length].to_i
    else
      length = 50
    end
    token = SecureRandom.urlsafe_base64(length)
    puts token
  end

  # How to use: 
  # bundle exec rake generate:evmethod["methodName","multiple","automatic","moduleName"]
  # bundle exec rake generate:evmethod["methodName","multiple","automatic","moduleName"] RAILS_ENV=production
  # For instance: bundle exec rake generate:evmethod["LORI v1.5","false","false","Lori"]
  task :evmethod, [:name,:multiple,:automatic,:module_name,:plugin_name] => :environment do |t, args|
    puts "Generating new evaluation model"

    abort("Task aborted. Invalid Sintax for task 'bundle exec rake generate:evmethod[\"methodName\",\"multiple\",\"automatic\",\"moduleName\"]'") if args[:name].blank?

    if args[:module_name].blank?
      #Try to get from name
      moduleName = args[:name].split(" ")[0]
    else
      moduleName = args[:module_name]
    end
    moduleName = moduleName.split("_").map{|s| s.downcase.capitalize}.join("")

    if moduleName.pluralize == moduleName
      puts("The name '" + moduleName + "' needs an inflection rule since it has an irregular plural.")
      puts("You need to add the following line in the 'config/initializers/inflections.rb' file:")
      puts "inflect.irregular '" + moduleName + "', '" + moduleName + "es'"
      abort("Task aborted. Apply this change and execute the task again.")
    end
    moduleName = "Evaluations::" + moduleName

    multiple = (args[:multiple]=="true")
    automatic = (args[:automatic]=="true")

    plugin = args[:plugin_name]
    unless plugin.blank?
      #Validate plugin
      abort("Task aborted. Plugin " + plugin + " does not exist.") unless LOEP::Application::config.available_plugins.include?(plugin)
      abort("Task aborted. Plugin " + plugin + " is not enabled.") unless LOEP::Application::config.enabled_plugins.include?(plugin)
    end

    ev = Evmethod.where(:module => moduleName).first
    abort("Task aborted. An evaluation model with module '" + moduleName + "' already exists.") unless ev.nil?

    #Create the new ev method
    ev = Evmethod.new
    ev.name = args[:name]
    ev.module = moduleName
    ev.allow_multiple_evaluations = multiple
    ev.automatic = automatic
    ev.valid?

    if ev.errors.blank? and ev.save
      #Create model
      evaluationModelClassName = ev.module.split("Evaluations::")[1]
      modelContent = "# encoding: utf-8\n\n";
      modelContent += "class Evaluations::" + evaluationModelClassName + " < Evaluation\n";
      modelContent += "  # this is for Evaluations with evMethod=" + ev.name + " (type=" + evaluationModelClassName + "Evaluation)\n\n"
      modelContent += "  def init\n    self.evmethod_id ||= Evmethod.find_by_name(\"" + ev.name + "\").id\n    super\n  end\n\n"
      modelContent += "  def self.getItems\n    [\n      {\n        :name => \"Item1\",\n        :type=> \"integer\"\n      },{\n        :name => \"Item2\",\n        :type=> \"integer\"\n      }\n    ]\n  end\n\n"
      modelContent += "  def self.getScale\n    return [1,5]\n  end\n\n"
      modelContent += "end"
     
      modelFilePath = Rails.root.join.to_s
      modelFilePath += '/loep_plugins/' + plugin unless plugin.blank?
      modelFilePath += "/app/models/evaluations/"
      unless File.exists?(modelFilePath)
        require 'fileutils'
        FileUtils::mkdir_p modelFilePath
      end
      modelFilePath += evaluationModelClassName.split(/([[:upper:]][[:lower:]]*[0-9]*)/).delete_if(&:empty?).map{|s| s.downcase}.join("_") + ".rb"

      unless File.exist?(modelFilePath)
        File.open(modelFilePath, 'w') {|f| f.write(modelContent) }
        puts("The model was created in " + modelFilePath)
      end

      #Create controller
      evaluationControllerClassName = evaluationModelClassName.pluralize
      controllerContent = "class Evaluations::" + evaluationControllerClassName + "Controller < EvaluationsController\nend"
      
      controllerFilePath = Rails.root.join.to_s
      controllerFilePath += '/loep_plugins/' + plugin unless plugin.blank?
      controllerFilePath += "/app/controllers/evaluations/"
      unless File.exists?(controllerFilePath)
        require 'fileutils'
        FileUtils::mkdir_p controllerFilePath
      end
      controllerFilePath += evaluationControllerClassName.split(/([[:upper:]][[:lower:]]*[0-9]*)/).delete_if(&:empty?).map{|s| s.downcase}.join("_") + "_controller.rb"

      unless File.exist?(controllerFilePath)
        File.open(controllerFilePath, 'w') {|f| f.write(controllerContent) }
        puts("The controller was created in " + controllerFilePath)
      end
      
      puts "The evaluation model was succesfully generated"
      puts ev.to_json
    else
      puts "Some error has ocurred:"
      puts ev.errors.full_messages
      puts ""
      abort("Task aborted.")
    end
  end


  # How to use: 
  # bundle exec rake generate:metric["metricName","evMethodNames","moduleName"]
  # bundle exec rake generate:metric["metricName","evMethodNames","moduleName"] RAILS_ENV=production
  # For instance: bundle exec rake generate:metric["LOEM Arithmetic Mean","LOEM","LOEMAM"]
  task :metric, [:name,:evMethods,:module_name,:plugin_name] => :environment do |t, args|
    puts "Generating new metric"
    abort("Task aborted. Invalid Sintax for task 'bundle exec rake generate:metric[\"metricName\",\"evMethodNames\",\"moduleName\"]'") if args[:name].blank? or args[:evMethods].blank?

    if args[:module_name].blank?
      #Try to get from name
      moduleName = args[:name].split(" ").join("_").downcase.capitalize
    else
      moduleName = args[:module_name]
    end
    moduleName = "Metrics::" + moduleName

    #Validate evmethods
    evMethods = (Evmethod.find_all_by_name(args[:evMethods].split(",").map{|s| s.strip})) rescue []
    abort("Task aborted. Evmethods '" + args[:evMethods] + "' not found.") if evMethods.blank?

    plugin = args[:plugin_name]
    unless plugin.blank?
      #Validate plugin
      abort("Task aborted. Plugin " + plugin + " does not exist.") unless LOEP::Application::config.available_plugins.include?(plugin)
      abort("Task aborted. Plugin " + plugin + " is not enabled.") unless LOEP::Application::config.enabled_plugins.include?(plugin)
    end

    #Check that metric doesn't exists
    m = Metric.where(:name => moduleName).first
    abort("Task aborted. A metric with module name '" + moduleName + "' already exists.") unless m.nil?

    #Create model
    metricModelClassName = moduleName.split("Metrics::")[1]
    modelContent = "# encoding: utf-8\n\n";
    modelContent += "class Metrics::" + metricModelClassName + " < Metric\n";
    modelContent += "  #this is for Metrics with type=" + metricModelClassName + "\n"
    modelContent += "  #Override methods here\n\n"
    modelContent += "  def self.getLoScore(evData)\n  end\n"
    modelContent += "end"


    modelFilePath = Rails.root.join.to_s
    modelFilePath += '/loep_plugins/' + plugin unless plugin.blank?
    modelFilePath += "/app/models/metrics/"
    unless File.exists?(modelFilePath)
      require 'fileutils'
      FileUtils::mkdir_p modelFilePath
    end
    modelFilePath += metricModelClassName.downcase + ".rb"
    unless File.exist?(modelFilePath)
      File.open(modelFilePath, 'w') {|f| f.write(modelContent) }
      puts("The model was created in " + modelFilePath)
    end

    #Create database instance for the metric
    m = moduleName.constantize.new
    m.name = args[:name]
    m.evmethods.push(evMethods)
    m.valid?

    if m.errors.blank? and m.save
      puts "The metric was succesfully generated"
      puts m.to_json
    else
      puts "Some error has ocurred:"
      puts m.errors.full_messages
      abort("Task aborted")
    end
  end

end