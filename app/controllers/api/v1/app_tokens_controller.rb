# encoding: utf-8

class Api::V1::AppTokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # Usage example: POST api/v1/app_tokens.json?app_name=ViSH&auth_token=Te7M7SxRx-kzcdfgCjCjt07GCKGU482aKrt
  def create
    app_name = params[:app_name]
    auth_token = params[:auth_token]

    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end
 
    if app_name.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the app name."}
       return
    end

    if auth_token.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the app auth token."}
       return
    end
    
    @app = App.find_by_name(app_name)
    if @app.nil?
      logger.info("Application cannot found.")
      render :status=>401, :json=>{:message=>"Invalid app name."}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @app.ensure_authentication_token!
 
    if @app.auth_token != auth_token
      logger.info("App #{app_name} failed signin, auth_token \"#{auth_token}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid app auth token."}
    else
      render :status=>200, :json=>{:token=>@app.authentication_token}
    end
  end

  # Usage example: DELETE api/v1/app_tokens/theToken.json
  def destroy
    @app = App.find_by_authentication_token(params[:id])
    if @app.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @app.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

  # Usage example: DELETE api/v1/app_tokens.json?auth_token=theToken
  def destroy_my_token
    if params["auth_token"] == current_app.authentication_token
      current_app.reset_authentication_token!
      render :status=>200, :json=>{:token=>params["auth_token"]}
    else
      render :status=>404, :json=>{:message=>"Invalid token."}
    end
  end
 
end