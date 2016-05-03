class EvaluationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create, :embed]
  before_filter :authenticate_user_or_session_token, :only => [:create]
  before_filter :authenticate_session_token, :only => [:embed]
  before_filter :getEvModel, :only => [:new, :create, :embed, :print]
  before_filter :getLoForUsersOrApps, :only => [:embed]
  
  # GET /evaluations
  # GET /evaluations.json
  def index
    return redirect_to "/revaluations" unless current_user.isAdmin?

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

    return new_automatic if @evaluation.evmethod.automatic
    
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

  def new_automatic
    @evaluation = @evModel.createAutomaticEvaluation(@lo)
    unless @evaluation.nil? or @evaluation.new_record?
      flash[:notice] = I18n.t("evaluations.message.success.automatic", :evmethod => @evmethod.name)
    else
      flash[:alert] = I18n.t("evaluations.message.error.automatic", :evmethod => @evmethod.name)
    end
    redirect_to(:back)
  end

  # Embed evaluation forms in external apps (similar to new)
  # GET '/evaluations/:evmethod/embed'
  def embed
    @evaluation = @evModel.new
    @evmethod = @evaluation.evmethod
    if @sessionToken
      #Validate token permissions
      unless @sessionToken.is_a? SessionToken and @sessionToken.allow_to?("evaluate",{"lo" => @lo.id, "evmethod" => @evaluation.evmethod.id})
        @message = I18n.t("api.message.error.unauthorized")
        return render "application/embed_empty", :layout => 'embed'
      end
    end
    unless @evmethod.allowExternalEvaluations?
      @message = I18n.t("evaluations.message.error.external_evaluations_disabled")
      return render "application/embed_empty", :layout => 'embed'
    end
    @evmethodItems = @evModel.getItems

    @title = @evmethod.name + ": " + @lo.name
    @embed = true
    @evaluation.id_user_app = params[:id_user_app] unless params[:id_user_app].blank?

    render :embed, :layout => 'embed'
  end

  # View to print the web form
  def print
    @evaluation = @evModel.new
    @evmethod = @evaluation.evmethod
    @evmethodItems = @evModel.getItems
    
    render :print, :layout => 'embed'
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

    if @sessionToken
      #Validate token permissions
      unless @sessionToken.is_a? SessionToken and @sessionToken.allow_to?("evaluate",{"lo" => @evaluation.lo.id, "evmethod" => @evaluation.evmethod.id})
        @message = I18n.t("api.message.error.unauthorized")
        return render "application/embed_empty", :layout => 'embed'
      end
    end

    if params[:embed]
      unless @evaluation.evmethod.allowExternalEvaluations?
        @message = I18n.t("evaluations.message.error.external_evaluations_disabled")
        return render "application/embed_empty", :layout => 'embed'
      end
      action = "embed"
      @evaluation.external = true
      @evaluation.app_id = @app.id
      @evaluation.user_id = nil
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
          #Invalidate session Token 
          #Only 1 evaluation can be created with a session token, unless the token is 'multiple'
          @sessionToken.invalidate unless @sessionToken.nil? or @sessionToken.multiple

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
    evaluationParams.delete("user_id") if !evaluationParams.nil? and current_user.isAdmin?

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

  def getEvModel
    @evModel = self.class.name.sub("Controller", "").singularize.constantize
  end

  def getEvaluationParams
    evaluationParams = nil
    #Look for evaluation params
    params.each do |key,val|
      evaluationParams = val if val.is_a?(Hash)
    end
    #Validate score if present
    evaluationParams.delete("score") unless evaluationParams.blank? or evaluationParams["score"].blank? or Utils.is_numeric?(evaluationParams["score"])
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

end
