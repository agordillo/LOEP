class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :filterEMethods

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.all(:order => 'updated_at DESC')
    authorize! :index, @assignments

    session[:return_to_afterDestroy] = request.url
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignments }
    end
  end

  def rindex
    @assignments = current_user.assignments(:order => 'updated_at DESC')
    authorize! :rshow, @assignments

    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignments }
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @assignment = Assignment.find(params[:id])
    authorize! :show, @assignment

    session[:return_to_afterDestroy] = assignments_path
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/new
  # GET /assignments/new.json
  def new
    @assignment = Assignment.new
    authorize! :new, @assignment

    unless params[:lo_ids].nil?
      @plos = Lo.find(params[:lo_ids].split(","));
    end

    unless params[:user_ids].nil?
      @pusers = User.find(params[:user_ids].split(","));
    end

    session[:return_to] ||= request.referer
    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    @options_select = getOptionsForSelect
    
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
    authorize! :edit, @assignment

    session[:return_to] ||= request.referer
    session[:return_to_afterDestroy] = assignments_path

    @plos = [@assignment.lo]
    @pusers = [@assignment.user]
    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignment }
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignment = Assignment.new(params[:assignment])
    authorize! :create, @assignment
    
    if params[:selected_los].blank?
      return renderError("You must select at least one Learning Object to create an assignment.","new")
    end

    if params[:selected_users].blank?
      return renderError("You must select at least one Reviewer to create an assignment.","new")
    end

    assignments = []
    params[:selected_los].each do |lo_id|
      params[:selected_users].each do |user_id|
        #Create assignment for Lo with id lo_id and reviewer with id user_id
        as = Assignment.new
        as.assign_attributes(params[:assignment])
        as.author_id = current_user.id
        as.user_id = user_id
        as.lo_id = lo_id
        as.status = "Pending"
        assignments << as
      end
    end

    errors = []
    assignments.each do |as|
      as.valid?
      if !as.errors.blank?
        errors << as.errors
      end
    end
    
    respond_to do |format|
      if errors.empty?
        #Save assignments
        assignments.each do |as|
          unless as.save
            format.html {
              return renderError(as.errors.full_messages,"new")
            }
            format.json { 
              render json: as.errors, status: :unprocessable_entity
              return
            }
          end
        end
        format.html { redirect_to session.delete(:return_to), notice: 'Assignment was successfully created.' }
        format.json { render json: "Process completed", status: :created, location: assignments_path }
      else
        format.html {
            return renderError(errors[0].full_messages,"new") 
          }
        format.json { render json: errors[0], status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    @assignment = Assignment.find(params[:id])
    authorize! :update, @assignment

    #Adapt params
    unless params[:selected_los].blank?
      params[:assignment][:lo_id] = params[:selected_los][0]
    end
    unless params[:selected_users].blank?
      params[:assignment][:user_id] = params[:selected_users][0]
    end

    @los = Lo.all
    @users = User.reviewers
    @options_select = getOptionsForSelect

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { 
          redirect_to session.delete(:return_to),
          notice: 'Assignment was successfully updated.' 
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:alert] = @lo.errors.full_messages
          redirect_to session.delete(:return_to)
        }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment = Assignment.find(params[:id])
    authorize! :destroy, @assignment

    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to session.delete(:return_to_afterDestroy) }
      format.json { head :no_content }
    end
  end

  private

  def renderError(msg,action)
    buildViewParamsBeforeRenderError
    flash[:alert] = msg
    render action: action, :layout => "application_with_menu"
  end

  def buildViewParamsBeforeRenderError
    unless params[:selected_los].nil?
      @plos = Lo.find(params[:selected_los])
    end

    unless params[:selected_users].nil?
      @pusers = User.find(params[:selected_users])
    end

    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    @options_select = getOptionsForSelect
  end

  def getOptionsForSelect
    optionsForSelect = Hash.new
    optionsForSelect["status"] = [["Pending","Pending"],["Completed","Completed"],["Rejected","Rejected"]]
    #TODO, fill evMethods based on evMethod model
    optionsForSelect["eMethods"] = [["LORI v1.5","LORI"]]
    optionsForSelect
  end

  def filterEMethods
    if params[:assignment] and params[:assignment][:emethods]
      params[:assignment][:emethods] = params[:assignment][:emethods].reject{|m| m.empty? }.to_json
    end
  end

end
