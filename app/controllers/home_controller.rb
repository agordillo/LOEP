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
			@assignments = Assignment.all.sort{|b,a| a.compareAssignmentForAdmins(b)}.first(5)
			authorize! :index, @assignments
			@los = Lo.all(:order => 'created_at DESC').first(5)
			authorize! :index, @los
			@evaluations = Evaluation.all(:order => 'updated_at DESC').first(5)
			authorize! :index, @evaluations
			@users = User.all(:order => 'created_at DESC').first(5)
			authorize! :index, @users
			@apps = App.all(:order => 'created_at DESC').first(5)
			authorize! :index, @apps
		else
			@assignments = current_user.assignments.all.sort{|b,a| a.compareAssignmentForReviewers(b)}.first(10)
			authorize! :rshow, @assignments
			@evaluations = current_user.evaluations.all(:order => 'updated_at DESC').first(5)
			authorize! :rshow, @evaluations
		end

		Utils.update_sessions_paths(session, request.url, nil)
		respond_to do |format|
			format.html
		end
	end

end
