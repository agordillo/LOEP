# Be sure to restart your server when you modify this file.

LOEP::Application.config.version = "1.0.0"

#Secret key for verifying the integrity of signed cookies.
LOEP::Application.config.secret_token = LOEP::Application.config.APP_CONFIG['secret_token']

LOEP::Application.config.session_store :cookie_store, key: '_LOEP_session'

#Recaptcha
Recaptcha.configure do |config|
    config.public_key  = LOEP::Application.config.APP_CONFIG['recaptcha']['public_key']
    config.private_key = LOEP::Application.config.APP_CONFIG['recaptcha']['private_key']
end

if ActiveRecord::Base.connection.table_exists? "evmethods"
	#Configure the evaluation models you want to use in your LOEP instance
	#See app/models/evaluations for more possible methods to add
	LOEP::Application.config.evmethod_names = LOEP::Application.config.APP_CONFIG['evmethods'].reject{ |n| Evmethod.find_by_name(n).nil? }
	LOEP::Application.config.evmethods = LOEP::Application.config.evmethod_names.map{|n| Evmethod.find_by_name(n)}

	#Configure the metrics you want to use in your LOEP instance
	#See app/models/metrics for more possible metrics to add
	LOEP::Application.config.metric_names = LOEP::Application.config.APP_CONFIG['metrics'].reject{ |n|
		m = Metric.find_by_name(n);
		m.nil? or !(m.evmethods - LOEP::Application.config.evmethods).empty?
	}
	LOEP::Application.config.metrics = LOEP::Application.config.metric_names.map{|n| Metric.find_by_name(n)}

	#UI
	LOEP::Application.config.show_surveys = (LOEP::Application.config.APP_CONFIG['surveys']=="true")
end