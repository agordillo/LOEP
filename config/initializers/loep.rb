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

#Configure the metrics you want to use in your LOEP instance
#See app/models/metrics for more possible metrics to add
LOEP::Application.config.metrics = [Metrics::LORIAM, Metrics::LORIWAM]