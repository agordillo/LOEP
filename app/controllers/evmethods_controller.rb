class EvmethodsController < ApplicationController
	before_filter :authenticate_user!
	
	def show
		nickname = params[:id]
		@evmethod = Evmethod.getEvMethodFromNickname(nickname)
		render nickname
	end
end
