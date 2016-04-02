# Be sure to restart your server when you modify this file.

LOEP::Application.config.version = "1.0.1"

LOEP::Application.config.full_domain = "http://" + LOEP::Application.config.APP_CONFIG["domain"]

#Secret key for verifying the integrity of signed cookies.
LOEP::Application.config.secret_token = LOEP::Application.config.APP_CONFIG['secret_token']

LOEP::Application.config.session_store :cookie_store, key: '_LOEP_session'

#Recaptcha
LOEP::Application.config.enable_recaptcha = !LOEP::Application.config.APP_CONFIG['recaptcha'].blank?
if LOEP::Application.config.enable_recaptcha
  Recaptcha.configure do |config|
    config.public_key  = LOEP::Application.config.APP_CONFIG['recaptcha']['public_key']
    config.private_key = LOEP::Application.config.APP_CONFIG['recaptcha']['private_key']
  end
end

LOEP::Application.config.register_policy = LOEP::Application.config.APP_CONFIG['register_policy'] || "FREE"
LOEP::Application.config.default_role = LOEP::Application.config.APP_CONFIG['default_role'] || "User"

if ActiveRecord::Base.connection.table_exists? "evmethods" and ActiveRecord::Base.connection.table_exists? "metrics"
  #Configure the evaluation models you want to use in your LOEP instance
  #See app/models/evaluations for more possible methods to add
  LOEP::Application.config.evmethod_names = LOEP::Application.config.APP_CONFIG['evmethods'].reject{ |n| Evmethod.find_by_name(n).nil? }
  LOEP::Application.config.evmethods = LOEP::Application.config.evmethod_names.map{|n| Evmethod.find_by_name(n)}
  LOEP::Application.config.evmethods_ids = LOEP::Application.config.evmethods.map{|evmethod| evmethod.id }
  LOEP::Application.config.evmethods_human_ids = LOEP::Application.config.evmethods.reject{|ev| ev.automatic}.map{|evmethod| evmethod.id}
  
  #Configure the metrics you want to use in your LOEP instance
  #See app/models/metrics for more possible metrics to add
  LOEP::Application.config.metric_names = LOEP::Application.config.APP_CONFIG['metrics'].reject{ |n|
    m = Metric.find_by_name(n);
    m.nil? or !(m.evmethods - LOEP::Application.config.evmethods).empty?
  }
  LOEP::Application.config.metrics = LOEP::Application.config.metric_names.map{|n| Metric.find_by_name(n)}
end

#UI
LOEP::Application.config.show_surveys = (LOEP::Application.config.APP_CONFIG['surveys']=="true")