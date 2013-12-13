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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @evaluation }
    end
  end

  # GET /evaluations/new
  # GET /evaluations/new.json
  def new
    @evaluation = Evaluation.new
    authorize! :create, @evaluation

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @evaluation }
    end
  end

  # GET /evaluations/1/edit
  def edit
    @evaluation = Evaluation.find(params[:id])
    authorize! :edit, @evaluation
  end

  # POST /evaluations
  # POST /evaluations.json
  def create
    @evaluation = Evaluation.new(params[:evaluation])
    @evaluation.completed_at = Time.now
    authorize! :create, @evaluation

    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to home_path, notice: 'Evaluation was successfully submitted.' }
        format.json { render json: @evaluation, status: :created, location: @evaluation }
      else
        format.html { render action: "new" }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /evaluations/1
  # PUT /evaluations/1.json
  def update
    @evaluation = Evaluation.find(params[:id])
    authorize! :update, @evaluation

    respond_to do |format|
      if @evaluation.update_attributes(params[:evaluation])
        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
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
      format.html { redirect_to evaluations_url }
      format.json { head :no_content }
    end
  end
end
