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
		roleName = current_user.role_name

		case roleName
		when "SuperAdmin","Admin"
			@assignments = Assignment.allc.sort{|b,a| a.compareAssignmentForAdmins(b)}.first(5)
			authorize! :index, @assignments
			@los = Lo.all(:order => 'created_at DESC').first(5)
			authorize! :index, @los
			@evaluations = Evaluation.allc({:automatic => false}).order('updated_at DESC').first(5)
			authorize! :index, @evaluations
			@users = User.all(:order => 'created_at DESC').first(5)
			authorize! :index, @users
			@apps = App.all(:order => 'created_at DESC').first(5)
			authorize! :index, @apps
		when "Reviewer"
			@assignments = current_user.assignments.allc.sort{|b,a| a.compareAssignmentForReviewers(b)}.first(10)
			authorize! :rshow, @assignments
			@evaluations = current_user.evaluations.allc.sort_by{ |ev| ev.updated_at}.reverse.first(5)
			authorize! :rshow, @evaluations
		else
			#Users
		end

		Utils.update_sessions_paths(session, request.url, nil)
		respond_to do |format|
			format.html
		end
	end

end
