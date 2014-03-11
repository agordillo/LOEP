class ApplicationController < ActionController::Base
  protect_from_forgery

  #################
  #Configuration
  #################

  #Device path
  def after_sign_in_path_for(resource)
	  sign_in_url = "/home"
  end

  #CanCan Rescue
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to home_path, alert: exception.message
  end

  #Wildcard route rescue
  def page_not_found
    flash[:alert] = "This page does not exists"
    redirect_to home_path, alert: flash[:alert]
  end


  #Web Services

  def serve_tags
    term = params["term"].downcase;
    if term.length < 2
      render :json => Hash.new
      return
    end
    @tags = _getTags
    render :json => @tags.reject{|tag| _rejectTag(tag,term) }
  end

  def generateToken
    :authenticate_user!
    length = (params[:length].nil? ? 64 : params[:length].to_i)
    render :json => { :token => Utils.build_token(length)}
  end

  private

  def _getTags
    constants = JSON(File.read("public/constants.json"))
    staticTags = constants["tags"]
    categoriesTags = constants["categories"]
    popularTags = _getPopularTags.map { |tag| tag.name }
    tags = (staticTags + categoriesTags + popularTags).uniq
    tags.sort_by!{ |tag| tag.downcase } #sort it alphabetically
  end

  def _getPopularTags
    User.tag_counts.order(:count).limit(80)

    # mtags = ActsAsTaggableOn::Tagging.
    #         includes(:tag).
    #         # where(:context => "topics").
    #         group("tags.name").
    #         select("tags.name, COUNT(*) as count")
    # mtags.count
  end

  def _rejectTag(tag,term)
  	if tag.downcase.include? term
  		false
  	else
  		true
  	end
  end

end
