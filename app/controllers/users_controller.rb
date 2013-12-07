class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		@users = User.all.sort_by {|user| user.compareRole }.reverse
		authorize! :index, @users
	end

	def show
		@user = User.find(params[:id])
		authorize! :show, @user
	end

	def edit
		@user = User.find(params[:id])
		authorize! :edit, @user
		session[:return_to] ||= request.referer
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
  			redirect_to session.delete(:return_to)
  		else
  			flash[:alert] = @user.errors.full_messages.to_sentence
  			render :action => "edit"
  		end
	end

end