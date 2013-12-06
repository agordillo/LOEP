class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
	  sign_in_url = "/home"
  end

  def serve_tags
  	term = params["term"].downcase;
  	@tags = JSON(File.read("public/tag_list.json"))
  	@popularTags = User.tag_counts.order(:count).limit(50)
  	#TODO: Merge @tag array and @popularTags record
  	render :json => @tags.reject{|tag| _rejectTag(tag,term) }
  end

  #CanCan Rescue
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  private

  def _rejectTag(tag,term)
  	if tag.downcase.include? term
  		false
  	else
  		true
  	end
  end

end
