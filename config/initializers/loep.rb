# Be sure to restart your server when you modify this file.
LOEP::Application.configure do
  config.version = "1.1"
  config.full_domain = "http://" + config.APP_CONFIG["domain"]
  #Secret key for verifying the integrity of signed cookies.
  config.secret_token = config.APP_CONFIG['secret_token']
  config.session_store :cookie_store, key: '_LOEP_session'

  #Recaptcha
  config.enable_recaptcha = !config.APP_CONFIG['recaptcha'].blank?
  if config.enable_recaptcha
    Recaptcha.configure do |config|
      config.site_key  = LOEP::Application::config.APP_CONFIG['recaptcha']['public_key']
      config.secret_key = LOEP::Application::config.APP_CONFIG['recaptcha']['private_key']
    end
  end

  config.register_policy = config.APP_CONFIG['register_policy'] || "FREE"
  config.default_role = config.APP_CONFIG['default_role'] || "User"

  #Plugins
  config.available_plugins = []
  pluginsPath = "./loep_plugins"
  if File.directory?(pluginsPath)
    Dir.glob(pluginsPath+"/*").select {|f| File.directory? f}.each do |f|
      config.available_plugins << f.gsub(pluginsPath+"/","")
    end
  end

  config.enabled_plugins = []
  if config.APP_CONFIG['plugins'].is_a? Array
    config.enabled_plugins = (config.APP_CONFIG['plugins'] & config.available_plugins)
  end

  if ActiveRecord::Base.connection.table_exists? "evmethods" and ActiveRecord::Base.connection.table_exists? "metrics"
    #Configure the evaluation models you want to use in your LOEP instance
    #See app/models/evaluations for more possible methods to add
    config.evmethod_names = config.APP_CONFIG['evmethods'].reject{ |n| Evmethod.find_by_name(n).nil? }
    config.evmethods = config.evmethod_names.map{|n| Evmethod.find_by_name(n)}
    config.evmethods_ids = config.evmethods.map{|evmethod| evmethod.id }
    if ActiveRecord::Base.connection.column_exists?("evmethods","automatic")
      config.evmethods_human_ids = config.evmethods.reject{|ev| ev.automatic}.map{|evmethod| evmethod.id}
    else
      config.evmethods_human_ids = config.evmethods.map{|evmethod| evmethod.id}
    end

    #Configure the metrics you want to use in your LOEP instance
    #See app/models/metrics for more possible metrics to add
    config.metric_names = config.APP_CONFIG['metrics'].reject{ |n|
      m = Metric.find_by_name(n);
      m.nil? or !(m.evmethods - config.evmethods).empty?
    }
    config.metrics = config.metric_names.map{|n| Metric.find_by_name(n)}
  end

  if ActiveRecord::Base.connection.table_exists? "los"
    #Get all repositories (nil means all repositories)
    config.repositories = (Lo.all.map{|lo| lo.repository} + [nil]).uniq
  end
end
