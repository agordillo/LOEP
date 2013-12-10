class AssignmentsController < ApplicationController
  before_filter :authenticate_user!


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

    @options_select = getOptionsForSelect
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render json: @assignment, status: :created, location: @assignment }
      else
        format.html { 
          flash[:alert] = @lo.errors.full_messages
          render action: "new", :layout => "application_with_menu" 
        }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    @assignment = Assignment.find(params[:id])

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

  private

  def getOptionsForSelect
    optionsForSelect = Hash.new
    optionsForSelect["status"] = [["Pending","Pending"],["Completed","Completed"],["Rejected","Rejected"]]
    #TODO, fill evMethods based on evMethod model
    optionsForSelect["eMethods"] = [["LORI v1.5","1"]]
    optionsForSelect
  end

end
