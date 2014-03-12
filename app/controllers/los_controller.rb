class LosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :filterCategories
  before_filter :filterLanguage

  # GET /los
  # GET /los.json
  def index
    @los = Lo.all(:order => 'name ASC')
    authorize! :index, @los

    Utils.update_sessions_paths(session, request.url, nil)
    
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @los }
    end
  end

  def publicIndex
    @los = Lo.Public.order('created_at DESC')
    authorize! :rshow, @los

    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @los }
    end
  end

  def rankedIndex
    @los = Lo.all
    authorize! :index, @los

    @metrics = Metric.all

    @los = Lo.orderByScore(@los,Metric.find_by_type("Metrics::LORIAM"))

    respond_to do |format|
      format.html
      format.json {
        render json: @los 
      }
    end
  end

  # GET /los/1
  # GET /los/1.json
  def show
    unless current_user.isAdmin?
      redirect_to "/rlos/" + params[:id]
      return
    end
    
    @lo = Lo.find(params[:id])
    authorize! :show, @lo

    @assignments = @lo.assignments.sort{|b,a| a.compareAssignmentForAdmins(b)}
    authorize! :index, @assignments

    @evaluations = @lo.evaluations.sort_by{ |ev| ev.updated_at}.reverse
    authorize! :index, @evaluations

    Utils.update_sessions_paths(session, los_path, request.url)
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @lo }
    end
  end

  #Reviewer show
  def rshow
    user = view_as_user

    @lo = Lo.find(params[:id])
    authorize! :rshow, @lo

    unless user.role?("Admin")
      @assignments = @lo.assignments.where(:user_id => user.id, :status => "Pending")
    else
      @assignments = @lo.assignments
    end
    authorize! :rshow, @assignments
    
    @evmethods = []
    Evmethod.all.each do |ev|
      if can?(:evaluate, @lo, ev)
        @evmethods << ev
      end  
    end

    unless user.role?("Admin")
      @evaluations = user.evaluations.where(:lo_id=>@lo.id)
      authorize! :rshow, @evaluations
    else
      @evaluations = @lo.evaluations
      authorize! :show, @evaluations
    end
    @evaluations = @evaluations.sort_by{ |ev| ev.updated_at}.reverse

    #After reject -> after destroy dependence
    Utils.update_sessions_paths(session, nil, request.url)
    
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @lo }
    end
  end

  # GET /los/new
  # GET /los/new.json
  def new
    @lo = Lo.new
    authorize! :create, @lo

    Utils.update_return_to(session,request)
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @lo }
    end
  end

  # GET /los/1/edit
  def edit
    @lo = Lo.find(params[:id])
    authorize! :edit, @lo

    Utils.update_return_to(session,request)
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html
      format.json { render json: @lo }
    end
  end

  # POST /los
  # POST /los.json
  def create
    @lo = Lo.new(params[:lo])
    authorize! :create, @lo

    @options_select = getOptionsForSelect
    respond_to do |format|
      if @lo.save 
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'Lo was successfully created.' }
        format.json { render json: @lo, status: :created, location: @lo }
      else
        format.html { 
          flash.now[:alert] = @lo.errors.full_messages
          render action: "new"
        }
        format.json { render json: @lo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /los/1
  # PUT /los/1.json
  def update
    @lo = Lo.find(params[:id])
    authorize! :update, @lo
    @options_select = getOptionsForSelect
    respond_to do |format|
      if @lo.update_attributes(params[:lo])
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'Lo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { 
          flash.now[:alert] = @lo.errors.full_messages
          render action: "edit"
        }
        format.json { render json: @lo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /los/1
  # DELETE /los/1.json
  def destroy
    @lo = Lo.find(params[:id])
    authorize! :destroy, @lo
    @lo.destroy

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  def removelist
    @los = Lo.find(params[:lo_ids].split(","));
    authorize! :destroy, @los

    @los.each do |lo|
      lo.destroy
    end

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  #Stats
  def stats
    @los = Lo.find(params[:lo_ids].split(","));
    getStatsForLos(@los)
  end

  def getStatsForLos(los)
    @los = los
    authorize! :show, @los

    #Get the average score
    @scores = []
    Metric.all.each do |m|
      metricScores = @los.map{|lo| lo.scores.select{|s| s.metric_id==m.id}}.map{|sA| sA.first}

      if metricScores.empty? or !metricScores.select{|ms| ms.nil? }.empty?
        #To get stats from a set of LOs all of them should have been evaluated
        next
      end

      #Calculate average value
      sum = 0
      metricScores.map{|mS| sum = sum + mS.value}
      average = sum.to_f/metricScores.size

      score = Score.new
      score.metric_id = m.id
      score.value = average
      @scores << score
    end

    @evmethods = []
    @los.each do |lo|
      if lo.getScoreEvmethods.empty?
        @evmethods = []
        break
      end
      @evmethods = @evmethods + lo.getScoreEvmethods
    end
    @evmethods.uniq!
  end

  #Compare
  def compare
    @los = Lo.find(params[:lo_ids].split(","));
    authorize! :show, @los

    @metrics = Metric.all
    @los = Lo.orderByScore(@los,Metric.find_by_type("Metrics::LORIAM"))

    @evmethods = []
    @los.each do |lo|
      if lo.getScoreEvmethods.empty?
        @evmethods = []
        break
      end
      @evmethods = @evmethods + lo.getScoreEvmethods
    end
    @evmethods.uniq!
  end

  #Search
  def searchIndex
    @evmethods = Evmethod.all
    render 'search'
  end

  def search
    @params = params
    @evmethods = Evmethod.all

    #Search Logic
    #Params Example
    # {"utf8"=>"✓",
    # "authenticity_token"=>"hDBVxA7HIBZ3lGGY1vVx/M7OBWUCKfWnUJzbx0FiSus=",
    # "query"=>"QUERY",
    # "repository"=>"REPOSITORY",
    # "hasText"=>"1",
    # "hasImages"=>"1",
    # "hasVideos"=>"1",
    # "hasAudios"=>"1",
    # "hasQuizzes"=>"1",
    # "hasWebs"=>"1",
    # "hasFlashObjects"=>"1",
    # "hasApplets"=>"1",
    # "hasDocuments"=>"1",
    # "hasFlashcards"=>"1",
    # "hasVirtualTours"=>"1",
    # "hasEnrichedVideos"=>"1",
    # "evmethods_yes"=>["1", "2"],
    # "evmethods_no"=>["1", "2"],
    # "controller"=>"los",
    # "action"=>"search"}

    #Perform Search based on query param and parameters
    #TODO: Enhance with sphinx
   
    queries = []

    if !params["query"].blank?
       queries << "los.name LIKE '" + params["query"] + "'"
    end

    #Repository
    if !params["repository"].blank?
      queries << "los.repository='" + params["repository"] + "'"
    end

    if params["hasText"] == "1"
      queries << "los.hasText=true"
    end

    if params["hasImages"] == "1"
      queries << "los.hasImages=true"
    end

    if params["hasVideos"] == "1"
      queries << "los.hasVideos=true"
    end

    if params["hasAudios"] == "1"
      queries << "los.hasAudios=true"
    end

    if params["hasQuizzes"] == "1"
      queries << "los.hasQuizzes=true"
    end

    if params["hasWebs"] == "1"
      queries << "los.hasWebs=true"
    end

    if params["hasFlashObjects"] == "1"
      queries << "los.hasFlashObjects=true"
    end

    if params["hasApplets"] == "1"
      queries << "los.hasApplets=true"
    end

    if params["hasDocuments"] == "1"
      queries << "los.hasDocuments=true"
    end

    if params["hasFlashcards"] == "1"
      queries << "los.hasFlashcards=true"
    end

    if params["hasVirtualTours"] == "1"
      queries << "los.hasVirtualTours=true"
    end

    if params["hasEnrichedVideos"] == "1"
      queries << "los.hasEnrichedVideos=true"
    end

    query = Utils.composeQuery(queries)

    if !query.nil?
      @los = Lo.where(query)
    else
      @los = Lo.all
    end

    #Filter by evaluations

    #Evaluated
    if !params["evmethods_yes"].blank?
      Evmethod.find(params["evmethods_yes"]).each do |evmethod|
        @los = @los.select{|lo| lo.hasBeenEvaluatedWithEvmethod(evmethod)}
      end
    end

    #Non evaluated
    if !params["evmethods_no"].blank?
      Evmethod.find(params["evmethods_no"]).each do |evmethod|
        @los = @los.select{|lo| !lo.hasBeenEvaluatedWithEvmethod(evmethod)}
      end
    end

    authorize! :show, @los
  end

  #Render XLSX
  def download
    Lo.find(params[:lo_ids].split(",").map{|id| id.to_i})
    getXLSX(@los)
  end

  def getXLSX(los)
    format.xlsx {
      render xlsx: "excel_index", disposition: "attachment", filename: "LOEP_LOS.xlsx"
    }
  end

  private

  def getOptionsForSelect
    optionsForSelect = Hash.new
    constants = JSON(File.read("public/constants.json"))
    optionsForSelect["categories"] = getOptionsForSelectFromArray(constants["categories"].uniq.sort_by!{ |tag| tag.downcase })
    optionsForSelect["lotype"] = getOptionsForSelectFromArray(constants["lotype"].uniq)
    optionsForSelect["technology"] = getOptionsForSelectFromArray(constants["technology"].uniq)
    optionsForSelect["eltype"] = constants["eltype"].uniq
    optionsForSelect
  end

  def getOptionsForSelectFromArray(array)
    options_select = [];
    array.each do |e|
      options_select.push([e,e])
    end
    options_select
  end

  def filterCategories
    if params[:lo] and params[:lo][:categories]
      params[:lo][:categories] = params[:lo][:categories].reject{|c| c.empty? }.to_json
    end
  end

  def filterLanguage
    if params[:lo] and params[:lo][:language_id] and !Utils.is_numeric?(params[:lo][:language_id])
      params[:lo].delete :language_id
    end
  end

  def view_as_user
    if current_user.role?("Admin") and params[:as_user_id]
      @represented = User.find(params[:as_user_id])
    else
      current_user
    end
  end

end
