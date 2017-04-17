LOEP::Application.configure do
  #Config action mailer
  #http://edgeguides.rubyonrails.org/action_mailer_basics.html
  loepMailConf = config.APP_CONFIG["mail"]

  unless loepMailConf.nil?
    ActionMailer::Base.default :charset => "utf-8"
    config.action_mailer.default_url_options = {:host => config.APP_CONFIG["domain"]}
    
    if loepMailConf["type"] == "SENDMAIL"
      config.action_mailer.delivery_method = :sendmail
      ActionMailer::Base.default :from => loepMailConf["no_reply_mail"] unless loepMailConf["no_reply_mail"].blank?
      ActionMailer::Base.sendmail_settings = {
        :location => "/usr/sbin/sendmail",
        :arguments => "-i -t"
      }
    else
      config.action_mailer.delivery_method = :smtp
      if loepMailConf["gmail_credentials"].blank?
        ActionMailer::Base.default :from => loepMailConf["no_reply_mail"] unless loepMailConf["no_reply_mail"].blank?
        smtp_settings = {}
        smtp_settings[:address] = loepMailConf["address"].blank? ? "127.0.0.1" : loepMailConf["address"] #If no address is provided, use local SMTP server
        smtp_settings[:port] = loepMailConf["port"].blank? ? "25" : loepMailConf["port"]
        smtp_settings[:domain] = loepMailConf["domain"].blank? ? config.APP_CONFIG["domain"] : loepMailConf["domain"]
        smtp_settings[:user_name] = loepMailConf["username"] unless loepMailConf["username"].blank?
        smtp_settings[:password] = loepMailConf["password"] unless loepMailConf["password"].blank?
        smtp_settings[:enable_starttls_auto] = loepMailConf["enable_starttls_auto"].blank? ? true : (loepMailConf["enable_starttls_auto"]=="true")
        smtp_settings[:openssl_verify_mode] = loepMailConf["openssl_verify_mode"].blank? ? "none" : (loepMailConf["openssl_verify_mode"])
        config.action_mailer.smtp_settings = smtp_settings
      else
        #Use gmail Credentials
        config.action_mailer.smtp_settings = {
          :address => "smtp.gmail.com",
          :port => 587,
          :domain => "gmail.com",
          :user_name => loepMailConf["gmail_credentials"]["username"],
          :password => loepMailConf["gmail_credentials"]["password"],
          :authentication => "plain",
          :enable_starttls_auto => true
        }
      end
    end
  end
end