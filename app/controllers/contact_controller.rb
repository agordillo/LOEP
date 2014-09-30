class ContactController < ApplicationController
	before_filter :authenticate_user!

	def new
	end

	def send_mail
		success = false

		unless params[:message].nil?
			cMail = LoepMailer.contact_mail(current_user,params[:message])
			unless cMail.nil?
				cMail.deliver
				success = true
			end
		end

		respond_to do |format|
			format.html {
				if success
					flash[:notice] = I18n.t("contact.message.success.send")
				else
					flash[:alert] = I18n.t("contact.message.error.send")
				end
				redirect_to home_path
			}
		end
	end

end
