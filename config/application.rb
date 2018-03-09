require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module LOEP
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    #Load LOEP configuration
    config.APP_CONFIG = YAML.load_file("config/application_config.yml")[ENV["RAILS_ENV"] || "development"]

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    # config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

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

    #Load LOEP plugins
    config.before_configuration do
      config.enabled_plugins.each do |eplugin|
        $:.unshift File.expand_path("#{__FILE__}/../../loep_plugins/#{eplugin}/lib")
        require eplugin
      end
    end

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
    # rails will fallback to config.i18n.default_locale translation
    config.i18n.fallbacks = true
    # rails will fallback to en, no matter what is set as config.i18n.default_locale
    # config.i18n.fallbacks = [:en]

    # When I18n.config.enforce_available_locales is true we'll raise an I18n::InvalidLocale exception if the passed locale is unavailable.
    # The default is set to nil which will display a deprecation error.
    # If set to false we'll skip enforcing available locales altogether (old behaviour).
    config.i18n.enforce_available_locales = false
    # if one of the gems compete for pre-loading, we need to use
    I18n.config.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    #Add fonts to assets path
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    #Compile assets
    #rake assets:precompile RAILS_ENV=development

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
