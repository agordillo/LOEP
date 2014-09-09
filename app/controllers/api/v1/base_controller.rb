class Api::V1::BaseController < ActionController::Base

  #################
  # Authentication for Web Apps
  ################

  before_filter :authenticate_app

  #The authentication for web apps is performed based on the auth_token, without interact with device or CanCan
  #A web app has the same permissions as its owner
  #Only admins are allowed to use the API

  def authenticate_app
    if (params["app_name"].nil? and params["app_id"].nil?) or params["auth_token"].nil?
      render :json => ["Unauthorized"], :status => :unauthorized
      return
    end

    begin
      unless params["app_id"].nil?
        app = App.find(params["app_id"])
      else
        app = App.find_by_name(params["app_name"])
      end
    rescue
      render :json => ["Unauthorized"], :status => :unauthorized
      return
    end

    if app.nil? or app.auth_token.nil? or app.auth_token != params["auth_token"] or app.user.nil? or !app.user.isAdmin?
      render :json => ["Unauthorized"], :status => :unauthorized
      return
    end

    session[:app_id] = app.id
    @current_user = app.user

    #Basic authorization check
    authorize! :update, current_app
  end

  #Access to current app
  def current_app
    @current_app ||= App.find(session[:app_id]) if session[:app_id].present?
  end
  helper_method :current_app

end