class HomeController < ApplicationController
	before_filter :authenticate_user!, :except => [:frontpage]

	def frontpage
		if user_signed_in?
			redirect_to :controller=>'home', :action => 'index'
		end
	end

	def index
		if current_user.role?("Admin")
			@assignments =Assignment.limit(10).all(:order => 'updated_at DESC')
    		authorize! :index, @assignments
    		@los = Lo.limit(10).all(:order => 'updated_at DESC')
    		authorize! :index, @los
    		@users = User.limit(5).all(:order => 'updated_at DESC')
    		authorize! :index, @users
		else
			@assignments = current_user.assignments.limit(10).all(:order => 'updated_at DESC')
    		authorize! :rshow, @assignments
		end

		session[:return_to_afterDestroy] = request.url
		respond_to do |format|
      		format.html { render layout: "application_with_menu" }
    	end
	end

end
