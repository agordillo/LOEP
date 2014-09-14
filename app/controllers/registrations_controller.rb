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
  			flash.now[:alert] = I18n.t("login.message.error.captcha")
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
    if params[:user]

      #User language
      if params[:user][:language_id]
        begin
          Language.find(params[:user][:language_id])
        rescue
          params[:user].delete :language_id
        end
      end

      #User preferred languages
      if params[:user][:languages]
        begin
          params[:user][:languages] = params[:user][:languages].reject{|m| m.empty? }
          params[:user][:languages] = params[:user][:languages].map{|m| Language.find(m) }
        rescue
          params[:user][:languages] = []
        end
      end
    end
  end

end
