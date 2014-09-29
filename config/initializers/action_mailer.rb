LOEP::Application.configure do
  #Config action mailer
  #http://edgeguides.rubyonrails.org/action_mailer_basics.html
  loepMailConf = config.APP_CONFIG["mail"]
  unless loepMailConf.nil?
    config.action_mailer.default_url_options = { :host => config.APP_CONFIG["domain"] }
    
    if loepMailConf["type"] === "SENDMAIL"
      ActionMailer::Base.default :from => loepMailConf["no_reply_mail"]
      config.action_mailer.delivery_method = :sendmail
      ActionMailer::Base.sendmail_settings = {
        :location => "/usr/sbin/sendmail",
        :arguments => "-i -t"
      }
    else
      config.action_mailer.delivery_method = :smtp

      if !loepMailConf["gmail_credentials"].nil?
        config.action_mailer.smtp_settings = {
          address:              'smtp.gmail.com',
          port:                 587,
          domain:               config.APP_CONFIG["domain"],
          user_name:            loepMailConf["gmail_credentials"]["username"],
          password:             loepMailConf["gmail_credentials"]["password"],
          authentication:       'plain',
          enable_starttls_auto: true  }
      else
        #Local SMTP server
        #(Suppose you have a SMTP server on localhost:25)
        ActionMailer::Base.default :from => loepMailConf["no_reply_mail"]
        config.action_mailer.smtp_settings = {
          :address => "127.0.0.1",
          :port    => "25",
          :domain  => config.APP_CONFIG["domain"],
          :enable_starttls_auto => true,
          :openssl_verify_mode  => 'none'
        }
      end
    end
  end
end