class HomeController < ApplicationController
	before_filter :authenticate_user!, :except => [:frontpage]

	def frontpage
		if user_signed_in?
			redirect_to :controller=>'home', :action => 'index'
			return
		end
		respond_to do |format|
      		format.html { render layout: "application_without_menu" }
    	end
		
	end

	def index
		if current_user.role?("Admin")
			@assignments =Assignment.limit(10).all(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForAdmins }.reverse
    		authorize! :index, @assignments
    		@los = Lo.limit(10).all(:order => 'updated_at DESC')
    		authorize! :index, @los
    		@users = User.limit(5).all(:order => 'updated_at DESC')
    		authorize! :index, @users
    		@evaluations = Evaluation.limit(5).all(:order => 'updated_at DESC')
    		authorize! :index, @evaluations
		else
			@assignments = current_user.assignments.limit(10).all(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForReviewers }.reverse
    		authorize! :rshow, @assignments
    		@evaluations = current_user.evaluations.limit(5).all(:order => 'updated_at DESC')
    		authorize! :rshow, @evaluations
		end

		Utils.update_sessions_paths(session, request.url, nil)
		respond_to do |format|
      		format.html
    	end
	end

end
