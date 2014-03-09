class RegistrationsController < Devise::RegistrationsController
  before_filter :filterULanguages

  def edit
    authorize! :edit, resource
    super
  end

  def create
  	@user = User.new
    @user.assign_attributes(params[:user])
    #Add role
    @user.roles.push(Role.reviewer)
    
  	@user.valid?

  	if @user.errors.blank?
  		if verify_recaptcha
  			@user.save
  			sign_in @user, :bypass => true
  			redirect_to "/"
  		else
  			flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
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

  private

  def filterULanguages
    if params[:user] and params[:user][:languages]
      begin
        params[:user][:languages] = params[:user][:languages].reject{|m| m.empty? }
        params[:user][:languages] = params[:user][:languages].map{|m| Language.find(m) }
      rescue
        params[:user][:languages] = []
      end
    end
    if params[:user] and params[:user][:language_id] and !Utils.is_numeric?(params[:user][:language_id])
      params[:user].delete :language_id
    end
  end

end
