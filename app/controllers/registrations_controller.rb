class RegistrationsController < Devise::RegistrationsController

  def edit
    authorize! :edit, resource
    super
  end

  def create
  	@user = User.new
  	@user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.birthday = params[:user][:birthday]
  	@user.gender = params[:user][:gender]
    @user.lan = params[:user][:lan]
    @user.tag_list = params[:user][:tag_list]
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

  def update
    authorize! :update, resource

    #Its not possible to change the roles here, because
    #params[:user][:roles] access is restricted for security reasons
    #Try to pass this param will trigger a "Can't mass-assign protected attributes: roles" error
    super
  end

end
