class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :filterULanguages

	def index
		@users = User.all.sort{|b,a| a.compareUsers(b)}
		authorize! :index, @users

		Utils.update_sessions_paths(session, request.url, nil)

		respond_to do |format|
			format.html
			format.json { render json: @users }
		end
	end

	def show
		@user = User.find(params[:id])
		authorize! :show, @user

		if current_user.isAdmin?
			@assignments = @user.assignments.sort{|b,a| a.compareAssignmentForAdmins(b)}
			authorize! :show, @assignments
			@evaluations = @user.evaluations.allc.sort_by{ |ev| ev.updated_at}.reverse
			authorize! :show, @evaluations
		else
			@assignments = @user.assignments.sort{|b,a| a.compareAssignmentForReviewers(b)}
			authorize! :rshow, @assignments
			@evaluations = @user.evaluations.allc.sort_by{ |ev| ev.updated_at}.reverse
			authorize! :rshow, @evaluations
		end

		Utils.update_sessions_paths(session, nil, nil)

		respond_to do |format|
			format.html
			format.json { render json: @user }
		end
	end

	def edit
		@user = User.find(params[:id])
		authorize! :edit, @user

		Utils.update_return_to(session,request)
	    respond_to do |format|
	      format.html
	      format.json { render json: @user }
	    end
	end

	# Users are created only by the registrations controller
	# def create
	# end

	def update
		@user = User.find(params[:id])
		authorize! :update, @user

		#params[:user][:roles] access is restricted for security reasons
		#Try to pass this param will trigger a "Can't mass-assign protected attributes: roles" error

		#This is the only way to change the role of a user
		#The method current_user.canChangeRole?(@user,role)
	    #ensure that the current_user has the required permissions to make this change

		if params["role"]
			role = Role.find_by_name(params["role"])
			unless current_user.canChangeRole?(@user,role)
				flash.now[:alert] = I18n.t("dictionary.forbidden_action")
				return render :action => "edit"
			else
				@user.assignRole(role)
			end
		end

		@user.assign_attributes(params[:user])
		@user.valid?

  		if @user.errors.blank?
  			@user.save
  			flash[:notice] = I18n.t("users.message.success.update")
  			return redirect_to Utils.return_after_create_or_update(session)
  		else
  			flash.now[:alert] = @user.errors.full_messages.to_sentence
  			return render :action => "edit"
  		end
	end

	def destroy
	    @user = User.find(params[:id])
	    authorize! :destroy, @user

	    @user.destroy
	    respond_to do |format|
	      format.html { redirect_to Utils.return_after_destroy_path(session) }
	      format.json { head :no_content }
	    end
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