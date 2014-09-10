class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
 
  ################
  # I18n support
  ################

  def set_locale
    I18n.locale = params[:locale] || user_preferred_locale || session[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
  end


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


  ################
  # Web services
  ################

  def serve_tags
    term = params["term"].downcase
    if term.length < 2
      render :json => Hash.new, :content_type => "application/json"
      return
    end
    render :json => getTags.select{|tag| acceptTag(tag,term) }, :content_type => "application/json"
  end

  def generateToken
    :authenticate_user!
    length = (params[:length].nil? ? 64 : params[:length].to_i)
    render :json => { :token => Utils.build_token(App,length)}
  end


  private

  ################
  # I18n support
  ################

  def extract_locale_from_accept_language_header
    return nil if request.env['HTTP_ACCEPT_LANGUAGE'].nil?
    (request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).map{|l| l.to_sym} & I18n.available_locales).first
  end

  def user_preferred_locale
    return nil unless user_signed_in?
    if I18n.available_locales.include? current_user.language.sym
      current_user.language.sym
    else
      (current_user.languages.map{|l| l.sym} & I18n.available_locales).first
    end
  end


  ################
  # Utils
  ################

  def getTags
    constants = JSON(File.read("public/constants.json"))
    staticTags = constants["tags"]
    categoriesTags = constants["categories"]
    popularTags = getPopularTags.map { |tag| tag.name }
    tags = (staticTags + categoriesTags + popularTags).uniq
    tags.sort_by!{ |tag| tag.downcase } #sort it alphabetically
  end

  def getPopularTags
    User.tag_counts.order(:count).limit(80)
  end

  def acceptTag(tag,term)
    tag.downcase.include? term
  end

end
