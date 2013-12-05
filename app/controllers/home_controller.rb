class HomeController < ApplicationController
	before_filter :authenticate_user!, :except => [:frontpage]

	def frontpage
		if user_signed_in?
			redirect_to :controller=>'home', :action => 'index'
		end
	end

	def index

	end

end
