class EvmethodsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :build_evmethod_params
	
	def show
		render :documentation
	end

	def documentation
	end

	def representation
	end


	private

	def build_evmethod_params
		@shortname = params[:id]
		@evmethod = Evmethod.getEvMethodFromShortname(@shortname)
	end
end
