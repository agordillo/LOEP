class LoepMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
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

  def contact_mail(user,body)
    unless body.blank?
      @user = user
      @body = body
      mail(to: LOEP::Application.config.APP_CONFIG["mail"]['main_mail'], subject: I18n.t("contact.mail_subject"))
    else
      nil
    end
  end

end