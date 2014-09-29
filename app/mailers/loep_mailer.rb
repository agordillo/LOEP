class LoepMailer < ActionMailer::Base
  default from: LOEP::Application.config.APP_CONFIG["mail"]['no_reply_mail']

  def invitation(email,body)
    if !email.blank? and !body.blank?
      @email = email
      @body = body
      mail(to: @email, subject: I18n.t("icodes.mail.invitation_subject"))
    else
      nil
    end
  end

end