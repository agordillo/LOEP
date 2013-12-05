class RegistrationsController < Devise::RegistrationsController

def new
	@user = User.new
end

def create
	@user = User.new
	@user.name = params[:user][:name]
	@user.birthday = params[:user][:birthday]
	@user.email = params[:user][:email]
	@user.password = params[:user][:password]
	@user.password_confirmation =params[:user][:password_confirmation]
	@user.valid?

	if @user.errors.blank?
		if verify_recaptcha
			@user.save
			redirect_to "/home"
		else
			flash[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
			render :action => "new"
		end
	else
		render :action => "new"
	end
end

end
