class AssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :filterEMethods

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.all

    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignments }
    end
  end

  def rindex
    @assignments = current_user.assignments

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

    unless params[:lo_ids].nil?
      @plos = Lo.find(params[:lo_ids].split(","));
    end

    unless params[:user_ids].nil?
      @pusers = User.find(params[:user_ids].split(","));
    end

    @los = Lo.all.reject{ |lo| @plos.include? lo unless @plos.nil?}
    @users = User.reviewers.reject{ |user| @pusers.include? user unless @pusers.nil? }
    @options_select = getOptionsForSelect

    session[:return_to] ||= request.referer
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])

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
    
    #For render actions...
    @los = Lo.all
    @users = User.reviewers
    @options_select = getOptionsForSelect

    if params[:selected_los].blank?
      flash[:alert] = "You must select at least one Learning Object to create an assignment."
      render action: "new", :layout => "application_with_menu" 
    end

    if params[:selected_users].blank?
      flash[:alert] = "You must select at least one Reviewer to create an assignment."
      render action: "new", :layout => "application_with_menu" 
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

              flash[:alert] = as.errors.full_messages
              render action: "new", :layout => "application_with_menu"
            }
            format.json { render json: as.errors, status: :unprocessable_entity }
          end
        end
        format.html { redirect_to assignments_path, notice: 'Assignment was successfully created.' }
        format.json { render json: "Process completed", status: :created, location: assignments_path }
      else
        format.html {
            #Create dummy assigment to refill format fields
            @assignment = Assignment.new
            @assignment.assign_attributes(params[:assignment])
            flash[:alert] = @errors[0].full_messages
            render action: "new", :layout => "application_with_menu" 
          }
        format.json { render json: @errors[0], status: :unprocessable_entity }
      end

    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    @assignment = Assignment.find(params[:id])

    @los = Lo.all
    @users = User.reviewers
    @options_select = getOptionsForSelect

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
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
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url }
      format.json { head :no_content }
    end
  end

  private

  def getOptionsForSelect
    optionsForSelect = Hash.new
    optionsForSelect["status"] = [["Pending","Pending"],["Completed","Completed"],["Rejected","Rejected"]]
    #TODO, fill evMethods based on evMethod model
    optionsForSelect["eMethods"] = [["LORI v1.5","1"]]
    optionsForSelect
  end

  # def getOptionsForSelectWithLosAndUsers(los,users)
  #   optionsForSelect = getOptionsForSelect
  #   optionsForSelect["los"] = getOptionsForSelectFromRecord(los)
  #   optionsForSelect["users"] = getOptionsForSelectFromRecord(los)
  # end

  # def getOptionsForSelectFromRecord(record)
  #   options_select = [];
  #   record.each do |e|
  #     options_select.push([e.name,e.id])
  #   end
  #   options_select
  # end

  def filterEMethods
    if params[:assignment] and params[:assignment][:emethods]
      params[:assignment][:emethods] = params[:assignment][:emethods].reject{|m| m.empty? }.to_json
    end
  end

end
