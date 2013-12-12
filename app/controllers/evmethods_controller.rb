class EvmethodsController < ApplicationController

	def show
		nickname = params[:id]
		@evmethod = Evmethod.getEvMethodFromNickname(nickname)
		render nickname
	end
end
