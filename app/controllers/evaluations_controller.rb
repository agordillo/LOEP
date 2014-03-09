class EvaluationsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /evaluations
  # GET /evaluations.json
  def index
    unless current_user.isAdmin?
      redirect_to "/revaluations"
      return
    end

    @evaluations = Evaluation.all
    authorize! :show, @evaluations

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @evaluations }
    end
  end

  def rindex
    @evaluations = current_user.evaluations(:order => 'updated_at DESC')
    authorize! :rshow, @evaluations

    Utils.update_sessions_paths(session, nil, nil)
    respond_to do |format|
      format.html 
      format.json { render json: @evaluations }
    end
  end

  # GET /evaluations/1
  # GET /evaluations/1.json
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
    new(Evaluation)
  end

  def new(evModel)
    @evaluation = evModel.new
    authorize! :new, @evaluation

    @lo = Lo.find(params[:lo_id])
    authorize! :rshow, @lo

    @evmethod = @evaluation.evmethod

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

    #Reviewers go to Home after create new evaluation
    if !current_user.role?("Admin")
      session[:return_to] = Rails.application.routes.url_helpers.home_path
    end

    respond_to do |format|
      format.html
      format.json { render json: @evaluation }
    end
  end

  # GET /evaluations/1/edit
  def edit
    @evaluation = Evaluation.find(params[:id])
    authorize! :edit, @evaluation

    Utils.update_sessions_paths(session, evaluations_path, nil)
    Utils.update_return_to(session,request)

    buildViewParamsBeforeRender
  end

  # POST /evaluations
  # POST /evaluations.json
  def create
    create(Evaluation)
  end

  def create(evModel)
    evaluationParams = getEvaluationParams
    @evaluation = evModel.new(evaluationParams)
    @evaluation.completed_at = Time.now
    authorize! :create, @evaluation

    @evaluation.valid?

    respond_to do |format|
      if @evaluation.errors.blank?
        if @evaluation.save
          format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'The evaluation was successfully submitted.' }
        else
          format.html { renderError("An error occurred and the evaluation could not be created. Check all the fields and try again.","new") }
        end
      else
        format.html { renderError(@evaluation.errors.full_messages,"new") }
      end
    end
  end

  def update
    @evaluation = Evaluation.find(params[:id])
    authorize! :update, @evaluation

    evaluationParams = getEvaluationParams

    if current_user.isAdmin?
      evaluationParams.delete("user_id")
    end

    respond_to do |format|
      if @evaluation.update_attributes(evaluationParams)
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'The evaluation was successfully updated.' }
      else
        format.html { renderError("Evaluation cannot be updated. Wrong params.","edit") }
      end
    end
  end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
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

  def getEvaluationParams
    evaluationParams = nil
    evaluationParamsKey = nil
    #evaluationParamsKey = evaluation.class.name.gsub("::","_").underscore

    #Look for evaluation params
    params.each do |key,val|
      if val.is_a?(Hash)
        evaluationParamsKey = key
        evaluationParams = val
      end
    end

    #Validate score if present
    if !evaluationParams["score"].nil? and !Utils.is_numeric?(evaluationParams["score"])
      evaluationParams.delete("score")
    end

    evaluationParams
  end

  def renderError(msg,action)
    buildViewParamsBeforeRender
    flash[:alert] = msg
    render action: action
  end

  def buildViewParamsBeforeRender
    @lo = @evaluation.lo
    authorize! :rshow, @lo
    @evmethod = @evaluation.evmethod
  end

end
