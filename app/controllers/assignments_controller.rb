class AssignmentsController < ApplicationController
  before_filter :authenticate_user!

  # GET /assignments
  # GET /assignments.json
  def index
    unless current_user.isAdmin?
      redirect_to "/rassignments"
      return
    end

    @assignments = Assignment.allc.sort{|b,a| a.compareAssignmentForAdmins(b)}
    authorize! :index, @assignments

    Utils.update_sessions_paths(session, request.url, nil)

    respond_to do |format|
      format.html
      format.json { render json: @assignments }
    end
  end

  def rindex
    @assignments = current_user.assignments.allc.sort{|b,a| a.compareAssignmentForReviewers(b)}
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

    @evaluations = @assignment.evaluations.allc.sort_by{ |ev| ev.updated_at}.reverse
    authorize! :index, @evaluations

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

    #Default deadline
    @assignment.deadline = DateTime.now + 1.month
    
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
    end
  end

  def new_automatic
    new
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
    @evmethodids = [@assignment.evmethod.id]
    
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    create_assignments("new")
  end

  def create_automatic
    create_assignments("new_automatic")
  end

  def create_assignments(action)
    action = action.nil? ? "new" : action

    @assignment = Assignment.new(params[:assignment])
    authorize! :create, @assignment
    
    if params[:selected_los].blank?
      return renderError(I18n.t("assignments.message.error.at_least_one_lo"),action)
    end

    if params[:selected_users].blank?
      return renderError(I18n.t("assignments.message.error.at_least_one_reviewer"),action)
    end

    if params[:selected_evmethods].blank?
      return renderError(I18n.t("assignments.message.error.at_least_one_evmethod"),action)
    end

    assignments = [];

    if action == "new_automatic"
      ##############
      # Automatic assignment generation
      ##############

      if params[:selected_users].is_a? Array and params[:selected_users].include? "all"
        @users = User.reviewers
      else
        @users = User.find(params[:selected_users])
      end

      nepl = getNEPL
      if nepl.blank?
        return renderError(I18n.t("assignments.message.error.nepl_unspecified"),"new_automatic")
      end

      #LO-Reviewer Matching Criteria
      if params["mcriteria"].blank?
        return renderError(I18n.t("assignments.message.error.mcriteria_unspecified"),"new_automatic")
      end

      @los = Lo.find(params[:selected_los])
      @evMethods = Evmethod.find(params[:selected_evmethods]);

      #Lo-Reviewer Matching
      matchedAssignments = MatchingSystem.LoReviewerMatching(params["mcriteria"],nepl,@los,@users,params[:assignment])

      #Create one assignment per EvMethod
      @evMethods.each do |evMethod|
        matchedAssignments.each do |as|
          cAs = as.dup
          cAs.evmethod_id = evMethod.id
          assignments.push(cAs)
        end
      end
    else
      ##############
      # Manual assignment generation
      ##############
      params[:selected_los].each do |lo_id|
        params[:selected_users].each do |user_id|
          params[:selected_evmethods].each do |evmethod_id|
            #Create assignment for Lo with id lo_id, reviewer with id user_id and evmethod evmethod_id
            as = Assignment.new
            as.assign_attributes(params[:assignment])
            as.author_id = current_user.id
            as.user_id = user_id
            as.lo_id = lo_id
            as.evmethod_id = evmethod_id
            as.status = "Pending"
            assignments << as
          end
        end
      end
    end

    if assignments.blank?
      return renderError(I18n.t("assignments.message.error.automatic_generic"),action)
    end

    #Include an error on the errors Array will cause the massive assignment creation to fail
    errors = []
    warnings = []

    assignments.each do |as|
      as.valid?
      if !as.errors.blank?
        #Duplicated assignments are not allowed but this error only triggers a warning (to allow to create the rest of the assignments)
        unless as.errors.messages.length===1 and !as.errors.messages[:duplicated_assignments].nil?
          errors << as.errors
        else
          warnings << as.errors.full_messages[0]
        end
      end
    end
    
    respond_to do |format|
      if errors.empty?
        #Save assignments
        assignments.each do |as|
          if as.errors.blank?
            unless as.save
              format.html {
                return renderError(as.errors.full_messages,action)
              }
              format.json { 
                render json: as.errors, status: :unprocessable_entity
                return
              }
            end
          end
        end
        returnPath = (action=="new_automatic") ? Utils.return_after_create_or_update(session) : assignments_path
        flash[:notice] = I18n.t("assignments.message.success.create")
        flash[:warning] = warnings.uniq
        format.html { redirect_to returnPath }
        format.json { render json: I18n.t("dictionary.process_completed"), status: :created, location: returnPath }
      else
        format.html { return renderError(errors[0].full_messages,action) }
        format.json { render json: errors[0], status: :unprocessable_entity }
      end
    end
  end

  #get Number of Evaluations per Learning Object param
  def getNEPL
    if !params["NEPL"].blank? and Utils.is_numeric?(params["NEPL"])
      return params["NEPL"].to_i
    elsif params["NEPL"] == "other" and !params["NEPL_other"].blank? and Utils.is_numeric?(params["NEPL_other"])
      return params["NEPL_other"].to_i
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
    unless params[:selected_evmethods].blank?
      params[:assignment][:evmethod_id] = params[:selected_evmethods][0]
    end

    @los = Lo.all
    @users = User.reviewers

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { 
          redirect_to Utils.return_after_create_or_update(session),
          notice: I18n.t("assignments.message.success.update") 
        }
        format.json { head :no_content }
      else
        format.html {
          flash.now[:alert] = @assignment.errors.full_messages
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

  def removelist
    @assignments = Assignment.find(params[:assignment_ids].split(","))
    authorize! :destroy, @assignments

    @assignments.each do |as|
      as.destroy
    end

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  def complete
    @assignment = Assignment.find(params[:id])
    authorize! :complete, @assignment

    #Check user evaluations for this LO with this evmethod.
    evaluations = Evaluation.where(:user_id=>@assignment.user.id, :lo_id=>@assignment.lo.id, :evmethod_id=>@assignment.evmethod.id)

    if @assignment.evmethod.allow_multiple_evaluations
      minEvToComplete = 1
    else
      minEvToComplete = 1
    end

    if evaluations.length >= minEvToComplete
      #Complete assignment
      @assignment.markAsComplete
      @assignment.save!
    else
      flash[:alert] = I18n.t("assignments.message.error.mark_as_completed_without_evaluations")
    end

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
    flash.now[:alert] = msg
    render action: action
  end

  def buildViewParamsBeforeRenderError
    unless params[:selected_los].nil?
      @plos = Lo.find(params[:selected_los])
    end

    unless params[:selected_users].nil? or params[:selected_users].include? "all"
      @pusers = User.find(params[:selected_users])
    end

    unless params[:selected_evmethods].blank?
      @evmethodids = params[:selected_evmethods]
    end

    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
  end

end
