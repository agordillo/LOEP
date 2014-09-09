# encoding: utf-8

class Api::V1::SessionTokenController < Api::V1::BaseController

  # API REST for Session Tokens

  # GET /api/v1/session_token
  def index
    create
  end

  # POST /api/v1/session_token
  def create
    respond_with_token(current_app.create_session_token)
  end

  # POST /api/v1/session_token/current
  def current
    respond_with_token(current_app.current_session_token)
  end

  private

  def respond_with_token(sessionToken)
    respond_to do |format|
      format.any {
        unless sessionToken.nil?
          render :json => sessionToken
        else
          render json: {error:"Error creating session token"}, status: :unprocessable_entity
        end 
      }
    end
  end

end