class RegistrationsController < Devise::RegistrationsController

def new
	@user = User.new
end

def create
	@user = User.new
	@user.name = params[:user][:name]
	@user.gender = params[:user][:gender]
	@user.birthday = params[:user][:birthday]
	@user.email = params[:user][:email]
	@user.password = params[:user][:password]
	@user.password_confirmation =params[:user][:password_confirmation]
	#Add role
	@user.roles.push(Role.reviewer)

	@user.valid?

	if @user.errors.blank?
		if true || verify_recaptcha
			@user.save
			sign_in @user, :bypass => true
			redirect_to "/"
		else
			flash[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
			render :action => "new"
		end
	else
		render :action => "new"
	end
end

end
