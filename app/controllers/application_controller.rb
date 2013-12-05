class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
	return "/home"
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    return root_path
  end

  #CanCan Rescue
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

end
