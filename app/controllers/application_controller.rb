class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
 
  ################
  # I18n support
  ################

  def set_locale
    I18n.locale = available_locale_or_nil(params[:locale]) || user_preferred_locale || available_locale_or_nil(session[:locale]) || extract_locale_from_accept_language_header || I18n.default_locale
  end


  #################
  #Configuration
  #################

  #Device path
  def after_sign_in_path_for(resource)
    sign_in_url = "/home"
  end

  #Override CanCan defaults
  def current_ability
    #An application has the same permissions as its owner
    @current_ability ||= Ability.new(current_owner)
  end

  def current_subject
    if user_signed_in?
      @current_subject = current_user
    elsif app_signed_in?
      @current_subject = current_app
    else
      @current_subject = nil
    end
    @current_subject
  end
  helper_method :current_subject

  def current_owner
    if app_signed_in?
      @current_owner = current_app.user
    elsif user_signed_in?
       @current_owner = current_user
    else
      @current_owner = nil
    end
    @current_owner
  end
  helper_method :current_owner

  #CanCan Rescue
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html {
        flash[:alert] = exception.message
        redirect_to home_path, alert: exception.message
      }
      format.json { 
        render json: I18n.t("api.message.error.unauthorized")
      }
    end
  end

  #Wildcard route rescue
  def page_not_found
    respond_to do |format|
      format.html {
        flash[:alert] = I18n.t("dictionary.errors.page_not_found")
        redirect_to home_path, alert: flash[:alert]
      }
      format.json {
        render json: I18n.t("dictionary.errors.page_not_found")
      }
    end
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

  def available_locale_or_nil(locale)
    stringLocale = ([locale] & I18n.available_locales.map{|l| l.to_s}).first
    stringLocale.to_sym unless stringLocale.nil?
  end

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
    staticTags = I18n.translate("constants.tags")
    popularTags = getPopularTags.map { |tag| tag.name }
    tags = (staticTags + popularTags).uniq
    tags.sort_by!{ |tag| tag.downcase } #sort it alphabetically
  end

  def getPopularTags
    User.tag_counts.order(:count).limit(80)
  end

  def acceptTag(tag,term)
    tag.downcase.include? term
  end

end
