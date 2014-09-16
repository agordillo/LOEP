# encoding: utf-8

class Api::V1::TokensController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # Usage example: POST api/v1/tokens.json?email=admin@loep.com&password=demonstration
  def create
    email = params[:email]
    password = params[:password]

    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end
 
    if email.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user email and password."}
       return
    end
    
    @user=User.find_by_email(email.downcase)
    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
      return
    end
 
    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!
 
    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
    else
      render :status=>200, :json=>{:token=>@user.authentication_token}
    end
  end

  # Usage example: DELETE api/v1/tokens/theToken.json
  def destroy
    @user = User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params[:id]}
    end
  end

  # Usage example: DELETE api/v1/tokens.json?auth_token=theToken
  def destroy_my_token
    if params["auth_token"] == current_user.authentication_token
      current_user.reset_authentication_token!
      render :status=>200, :json=>{:token=>params["auth_token"]}
    else
      render :status=>404, :json=>{:message=>"Invalid token."}
    end
  end
 
end