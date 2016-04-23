loepMailConf = LOEP::Application.config.APP_CONFIG["mail"]

unless loepMailConf.nil? or loepMailConf["no_reply_mail"].nil? or !(loepMailConf["exception_notification_mails"].is_a? Array)
  Rails.application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[LOEP] ",
    :sender_address => '"Error notifier" <' + loepMailConf["no_reply_mail"] + '>',
    :exception_recipients => loepMailConf["exception_notification_mails"]
  }
end