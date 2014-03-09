class LoricsController < ApplicationController
	before_filter :authenticate_user!

	def new
		if !current_user.loric.nil?
			redirect_to edit_loric_path(current_user.loric)
			return
		end
		@loric = Loric.new
		@evmethod = Evmethod.find_by_name("LORI v1.5")
		respond_to do |format|
      		format.html
    	end
	end

	def create
		@loric = Loric.new(params[:loric])
		@evmethod = Evmethod.find_by_name("LORI v1.5")
		respond_to do |format|
	      if @loric.save 
	        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'Your answer was successfully stored.' }
	        format.json { render json: @loric, status: :created, location: @loric }
	      else
	        format.html { 
	          flash.now[:alert] = @loric.errors.full_messages
	          render action: "new"
	        }
	        format.json { render json: @loric.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def edit
		@loric = current_user.loric
		@evmethod = Evmethod.find_by_name("LORI v1.5")
		respond_to do |format|
      		format.html
    	end
	end

	def update
		@loric = current_user.loric
		@loric.assign_attributes(params[:loric])
		@loric.valid?

	    respond_to do |format|
	      if @loric.errors.blank?
	      	@loric.save
	        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'Your answer was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html {
	          flash.now[:alert] = @loric.errors.full_messages
	          render action: "edit"
	        }
	        format.json { render json: @lo.errors, status: :unprocessable_entity }
	      end
	    end
  	end

end
