class RegistrationsController < Devise::RegistrationsController
  before_filter :filterULanguages

  # GET /resource/sign_up
  def new
    if LOEP::Application.config.register_policy=="INVITATION_ONLY"
      if params[:icode].blank?
        flash[:alert] = I18n.t("login.message.error.invitation_required")
        return redirect_to "/"
      end

      icode = (params[:icode].blank? ? nil : Icode.find_by_code(params[:icode]))
      role = (icode.nil? ? nil : icode.getRole)
      if role.nil?
        flash[:alert] = I18n.t("login.message.error.invitation_invalid")
        return redirect_to "/"
      end
    end

    unless LOEP::Application.config.register_policy=="FREE"
      @icode = params[:icode]
    end

    build_resource({})
    respond_with self.resource
  end

  def edit
    authorize! :edit, resource
    super
  end

  def create
    @user = User.new
    @user.assign_attributes(params[:user])

    icode = (params[:icode].blank? ? nil : Icode.find_by_code(params[:icode]))
    @icode = params[:icode]

    case LOEP::Application.config.register_policy
    when "INVITATION_ONLY"
      if params[:icode].blank?
        flash.now[:alert] = I18n.t("login.message.error.invitation_required")
        return render :action => "new"
      end

      role = (icode.nil? ? nil : icode.getRole)
      if role.nil?
        flash.now[:alert] = I18n.t("login.message.error.invitation_invalid")
        return render :action => "new"
      end
    when "HYBRID"
      role = (icode.nil? ? nil : icode.getRole)
      if role.nil?
        role = Role.default
      end
    else
      #When "FREE" (default)
      role = Role.default
    end

    if role.nil?
      flash.now[:alert] = I18n.t("login.message.error.role_required")
      return render :action => "new"
    end

    #Add role
    @user.roles.push(role)

    @user.valid?

    if @user.errors.blank?
      if !LOEP::Application.config.enable_recaptcha or verify_recaptcha
        @user.save
        icode.invalidate unless icode.nil?
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
