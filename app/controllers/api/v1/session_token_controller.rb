# encoding: utf-8

class Api::V1::SessionTokenController < Api::V1::BaseController

  # API REST for Session Tokens

  # GET /api/v1/session_token
  def index
    create
  end

  # POST /api/v1/session_token
  def create
    sessionTokenParams = params["session_token"] || {}
    sessionTokenParams["action_params"] = {}
    unless sessionTokenParams["lo_id_repository"].blank?
      query = {:id_repository => sessionTokenParams["lo_id_repository"]}
      unless sessionTokenParams["repository"].blank?
        query[:repository] = sessionTokenParams["repository"]
        sessionTokenParams.delete("repository")
      end
      lo = current_app.los.limit(1).where(query).first
      sessionTokenParams["action_params"][:lo] = lo.id unless lo.nil?
      sessionTokenParams.delete("lo_id_repository")
    end
    unless sessionTokenParams["evmethod_name"].blank?
      evmethod = Evmethod.getEvMethodFromShortname(sessionTokenParams["evmethod_name"])
      sessionTokenParams["action_params"][:evmethod] = evmethod.id unless evmethod.nil?
      sessionTokenParams.delete("evmethod_name")
    end

    token = current_app.create_session_token(sessionTokenParams)
    authorize! :create, token

    respond_with_token(token)
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
          render :json => {auth_token: sessionToken.auth_token}, :content_type => "application/json"
        else
          render json: {error:"Error creating session token"}, status: :bad_request, :content_type => "application/json"
        end 
      }
    end
  end

end