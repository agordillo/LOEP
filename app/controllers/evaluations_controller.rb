class EvaluationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create, :embed]
  before_filter :authenticate_user_or_session_token, :only => [:create]
  before_filter :authenticate_session_token, :only => [:embed]
  before_filter :getEvModel, :only => [:new, :create, :embed]
  before_filter :getAppLo, :only => [:embed]
  
  # GET /evaluations
  # GET /evaluations.json
  def index
    unless current_user.isAdmin?
      redirect_to "/revaluations"
      return
    end

    @evaluations = Evaluation.allc
    authorize! :show, @evaluations

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @evaluations }
    end
  end

  # GET /revaluations
  # GET /revaluations.json
  def rindex
    @evaluations = current_user.evaluations.allc.sort_by{ |ev| ev.updated_at}.reverse
    authorize! :rshow, @evaluations

    Utils.update_sessions_paths(session, nil, nil)
    respond_to do |format|
      format.html 
      format.json { render json: @evaluations }
    end
  end

  # GET /evaluations/:id
  # GET /evaluations/:id.json
  def show
    @evaluation = Evaluation.find(params[:id])
    authorize! :show, @evaluation

    buildViewParamsBeforeRender

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @evaluation }
    end
  end

  # GET /evaluations/new
  # GET /evaluations/new.json
  def new
    @evaluation = @evModel.new
    authorize! :new, @evaluation

    @lo = Lo.find(params[:lo_id])
    authorize! :rshow, @lo

    @evmethod = @evaluation.evmethod
    @evmethodItems = @evModel.getItems

    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
    else
      #Inferred
      @assignment = @lo.assignments.where(:status=> "Pending", :user_id => current_user.id, :evmethod_id => @evmethod.id).first
    end
    if !@assignment.nil?
      authorize! :rshow, @assignment
    end

    Utils.update_return_to(session,request)

    #Reviewers go to Home after create new evaluation, when the evmethod only allows one evaluation
    if !current_user.role?("Admin") and !@evmethod.allow_multiple_evaluations
      session[:return_to] = Rails.application.routes.url_helpers.home_path
    end

    respond_to do |format|
      format.html
      format.json { render json: @evaluation }
    end
  end

  # Embed evaluation forms in external apps (similar to new)
  # GET '/evaluations/:evmethod/embed'
  def embed
    @evaluation = @evModel.new
    @evmethod = @evaluation.evmethod
    unless !LOEP::Application.config.APP_CONFIG['allow_external_evaluations'].nil? and LOEP::Application.config.APP_CONFIG['allow_external_evaluations'].include? @evmethod.name
      @message = I18n.t("evaluations.message.error.external_evaluations_disabled")
      render :embed_empty, :layout => 'embed'
      return
    end
    @evmethodItems = @evModel.getItems

    @title = @lo.name
    @embed = true

    render :embed, :layout => 'embed'
  end

  # GET /evaluations/:id/edit
  def edit
    @evaluation = Evaluation.find(params[:id])
    authorize! :edit, @evaluation

    Utils.update_sessions_paths(session, evaluations_path, nil)
    Utils.update_return_to(session,request)

    buildViewParamsBeforeRender
  end

  # POST /evaluations
  def create  
    evaluationParams = getEvaluationParams
    @evaluation = @evModel.new(evaluationParams)
    @evaluation.completed_at = Time.now

    if params[:embed]
      unless !LOEP::Application.config.APP_CONFIG['allow_external_evaluations'].nil? and LOEP::Application.config.APP_CONFIG['allow_external_evaluations'].include? @evaluation.evmethod.name
        @message = I18n.t("evaluations.message.error.external_evaluations_disabled")
        render :embed_empty, :layout => 'embed'
        return
      end
      action = "embed"
      @evaluation.anonymous = true
      @evaluation.app_id = @app.id
    else
      action = "new"
    end

    authorize! :create, @evaluation

    @evaluation.valid?

    respond_to do |format|
      if @evaluation.errors.blank? and @evaluation.save
        unless params[:embed]
          format.html { 
            redirect_to Utils.return_after_create_or_update(session), notice: I18n.t("evaluations.message.success.create") 
          }
        else
          #Invalidate session Token (Only 1 evaluation can be created with a session token)
          sessionToken = SessionToken.find_by_auth_token(params["session_token"])
          sessionToken.invalidate unless sessionToken.nil?

          format.html {
            render "embed_finish", :layout => 'embed' 
          }
          format.js {
            #Ajax
            render json: @evaluation, status: :created
          }
        end
      else
        format.html {
          renderError(@evaluation.errors.full_messages,action)
        }
        format.js {
            #Ajax
            render json: @evaluation.errors, status: :bad_request
          }
      end
    end
  end

  # PUT /evaluations/:id
  def update
    @evaluation = Evaluation.find(params[:id])
    authorize! :update, @evaluation

    evaluationParams = getEvaluationParams

    if !evaluationParams.nil? and current_user.isAdmin?
      evaluationParams.delete("user_id")
    end

    respond_to do |format|
      if @evaluation.update_attributes(evaluationParams)
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: I18n.t("evaluations.message.success.update") }
      else
        format.html { renderError(I18n.t("evaluations.message.error.generic_update"),"edit") }
      end
    end
  end

  # DELETE /evaluations/:id
  # DELETE /evaluations/:id.json
  def destroy
    @evaluation = Evaluation.find(params[:id])
    authorize! :destroy, @evaluation

    @evaluation.destroy

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end


  private

  def authenticate_user_or_session_token
    if params[:session_token]
      #Authenticate via session_token
      authenticate_session_token
    else
      #Authenticate user
      authenticate_user!
    end
  end

  def getEvModel
    @evModel = self.class.name.sub("Controller", "").singularize.constantize
  end

  def getEvaluationParams
    evaluationParams = nil

    #Look for evaluation params
    params.each do |key,val|
      if val.is_a?(Hash)
        evaluationParams = val
      end
    end

    #Validate score if present
    if !evaluationParams.nil? and !evaluationParams["score"].nil? and !Utils.is_numeric?(evaluationParams["score"])
      evaluationParams.delete("score")
    end

    evaluationParams
  end

  def renderError(msg,action)
    buildViewParamsBeforeRender(action)
    flash.now[:alert] = msg

    if action == "embed"
      layout = "embed"
    else
      layout = "application"
    end

    render action: action, :layout => layout
  end

  def buildViewParamsBeforeRender(action=nil)
    @lo = @evaluation.lo
    authorize! :rshow, @lo
    @evmethod = @evaluation.evmethod
    @evmethodItems = @evaluation.class.getItems

    if action=="embed"
      @title = @lo.name
      @embed = true
    end
  end


  ####################
  # Methods for Embed
  ####################

  def authenticate_session_token
    if (params["app_name"].nil? and params["app_id"].nil?) or params["session_token"].nil?
      @message = I18n.t("api.message.error.unauthorized")
      render :embed_empty, :layout => 'embed'
      return
    end

    begin
      unless params["app_id"].nil?
        @app = App.find(params["app_id"])
      else
        @app = App.find_by_name(params["app_name"])
      end
    rescue
      @message = I18n.t("api.message.error.unauthorized")
      render :embed_empty, :layout => 'embed'
      return
    end

    @sessionToken = params["session_token"]

    if @app.nil? or !@app.isSessionTokenValid(@sessionToken) or @app.user.nil? or !@app.user.isAdmin?
      @message = I18n.t("api.message.error.unauthorized")
      render :embed_empty, :layout => 'embed'
      return
    end

    @current_user = @app.user
  end

  def getAppLo
    if params[:use_id_loep].nil?
      @lo = @app.los.find_by_id_repository(params[:lo_id])
    else
      @lo = Lo.find_by_id(params[:lo_id])
    end

    if @lo.nil?
      @message = I18n.t("api.message.error.lo_unexists")
      render :embed_empty, :layout => 'embed'
      return
    end
  end

end
