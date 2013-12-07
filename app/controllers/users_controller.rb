class UsersController < ApplicationController
	before_filter :authenticate_user!

	def index
		@users = User.all.sort_by {|user| user.compareRole }.reverse
	end

	def show
		@user = User.find(params[:id])
	end

	def edit
		session[:return_to] ||= request.referer
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		@user.assign_attributes(params[:user])
		@user.assignRole(params["role"])
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