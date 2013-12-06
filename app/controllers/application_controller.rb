class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
	  sign_in_url = "/home"
  end

  #CanCan Rescue
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

end
