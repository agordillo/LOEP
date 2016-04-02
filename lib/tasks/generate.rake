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
  # bundle exec rake generate:evmethod["MethodName","ModuleName","multiple","automatic"]
  # bundle exec rake generate:evmethod["MethodName","ModuleName","multiple","automatic"] RAILS_ENV=production
  # For instance: bundle exec rake generate:evmethod["LORI v1.5","Lori","false","false"]
  task :evmethod, [:name,:module_name,:multiple,:automatic] => :environment do |t, args|
    puts "Generating new evaluation method"

    Evmethod.find_by_name("SUS").destroy unless Evmethod.find_by_name("SUS").nil? #TODO

    abort("Task aborted. Invalid Sintax for task 'bundle exec rake generate:evmethod[\"MethodName\",\"ModuleName\",\"Multiple\",\"Automatic\"]'") if args[:name].blank?

    if args[:module_name].blank?
      #Try to get from name
      moduleName = args[:name].split(" ")[0].downcase.capitalize
    else
      moduleName = args[:module_name]
    end
    if moduleName.pluralize == moduleName
      puts("The name '" + moduleName + "' needs an inflection rule since it has an irregular plural.")
      puts("You need to add the following line in the 'config/initializers/inflections.rb' file:")
      puts "inflect.irregular '" + moduleName + "', '" + moduleName + "es'"
      abort("Task aborted. Apply this change and execute the task again.")
    end
    moduleName = "Evaluations::" + moduleName

    begin
      moduleClass = moduleName.constantize
      # abort("Task aborted. Module '" + moduleName + "' already exists.") TODO
    rescue
      #Module not found
    end

    multiple = (args[:multiple]=="true")
    automatic = (args[:automatic]=="true")

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
      modelFilePath = Rails.root.join('app', 'models', 'evaluations').to_s + "/" + evaluationModelClassName.downcase + ".rb"
      File.open(modelFilePath, 'w') {|f| f.write(modelContent) }

      #Create controller
      evaluationControllerClassName = evaluationModelClassName.pluralize
      controllerContent = "class Evaluations::" + evaluationControllerClassName + "Controller < EvaluationsController\nend"
      controllerFilePath = Rails.root.join('app', 'controllers', 'evaluations').to_s + "/" + evaluationControllerClassName.downcase + "_controller.rb"
      File.open(controllerFilePath, 'w') {|f| f.write(controllerContent) }
      
      puts("The model was created in " + modelFilePath)
      puts("The controller was created in " + controllerFilePath)
      puts "The evaluation method was succesfully generated"
      puts ev.to_json
    else
      puts "Some error has ocurred:"
      puts ev.errors.full_messages
      puts ""
      abort("Task aborted.")
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

 