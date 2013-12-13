class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :filterEMethods

  # GET /assignments
  # GET /assignments.json
  def index
    unless current_user.isAdmin?
      redirect_to "/rassignments"
      return
    end

    @assignments = Assignment.all(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForAdmins }.reverse
    authorize! :index, @assignments

    Utils.update_sessions_paths(session, request.url, nil)
    respond_to do |format|
      format.html
      format.json { render json: @assignments }
    end
  end

  def rindex
    @assignments = current_user.assignments(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForReviewers }.reverse
    authorize! :rshow, @assignments

    Utils.update_sessions_paths(session, nil, nil)
    respond_to do |format|
      format.html
      format.json { render json: @assignments }
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @assignment = Assignment.find(params[:id])
    authorize! :show, @assignment

    Utils.update_sessions_paths(session, assignments_path, nil)
    respond_to do |format|
      format.html
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

    Utils.update_return_to(session,request)
    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
    authorize! :edit, @assignment

    Utils.update_sessions_paths(session, assignments_path, nil)
    Utils.update_return_to(session,request)

    @plos = [@assignment.lo]
    @pusers = [@assignment.user]
    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    respond_to do |format|
      format.html
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
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'Assignment was successfully created.' }
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

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { 
          redirect_to Utils.return_after_create_or_update(session),
          notice: 'Assignment was successfully updated.' 
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:alert] = @assignment.errors.full_messages
          render action: "edit"
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
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  def reject
    @assignment = Assignment.find(params[:id])
    authorize! :reject, @assignment

    @assignment.status = "Rejected"
    @assignment.save!

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  private

  def renderError(msg,action)
    buildViewParamsBeforeRenderError
    flash[:alert] = msg
    render action: action
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
  end

  def filterEMethods
    if params[:assignment] and params[:assignment][:evmethods]
      begin
        params[:assignment][:evmethods] = params[:assignment][:evmethods].reject{|m| m.empty? }
        params[:assignment][:evmethods] = params[:assignment][:evmethods].map{|m| Evmethod.find(m) }
      rescue
        params[:assignment][:evmethods] = []
      end
    end
  end

end
