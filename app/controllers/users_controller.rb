class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :filterULanguages

	def index
		@users = User.all(:order => 'updated_at DESC').sort_by {|user| user.compareRole }.reverse
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

		@assignments = @user.assignments(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForAdmins }.reverse
    	authorize! :rshow, @assignments

    	@evaluations = @user.evaluations(:order => 'updated_at DESC')
    	authorize! :rshow, @evaluations

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
		#The method @user.check_permissions_to_change_role(current_user, params["role"]) 
	    #ensure that the current_user has the required permissions to make this change

		if params["role"]
			if !@user.check_permissions_to_change_role(current_user, params["role"])
				flash[:alert] = "Forbidden action"
				render :action => "edit"
				return
			else
				@user.assignRole(params["role"])
			end
		end

		@user.assign_attributes(params[:user])
		@user.valid?

  		if @user.errors.blank?
  			@user.save
  			flash[:notice] = "User updated succesfully"
  			redirect_to Utils.return_after_create_or_update(session)
  		else
  			flash[:alert] = @user.errors.full_messages.to_sentence
  			render :action => "edit"
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