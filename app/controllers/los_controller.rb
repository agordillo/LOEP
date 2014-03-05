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

  def rankedIndex
    @los = Lo.all
    authorize! :index, @los

    @scores = LoriMetric.getScoreForLos(@los)
    @los.sort! { |a, b| 
      scoreA = @scores[a.id.to_s]
      scoreB = @scores[b.id.to_s]

      if scoreA.nil? and scoreB.nil?
        0
      elsif scoreA.nil?
        +1
      elsif scoreB.nil?
        -1
      else
        scoreB <=> scoreA
      end
    }

    respond_to do |format|
      format.html
      format.json {
        @vishData = @los.map { |lo| 
          info = Hash.new
          if lo.url.match("http://vishub.org/excursions/")
            info["vishId"] = lo.url.split("http://vishub.org/excursions/")[1]
          end
          info["loepId"] = lo.id.to_s
          info["score"] = @scores[lo.id.to_s]
          info
        }
        render json: @vishData 
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

    @assignments = @lo.assignments(:order => 'updated_at DESC').sort_by {|as| as.compareAssignmentForAdmins }.reverse
    authorize! :index, @assignments

    @evaluations = @lo.evaluations(:order => 'updated_at DESC')
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
    
    unless user.role?("Admin")
      evmethods = []
      @assignments.map { |as| evmethods.push(as.evmethod) }
      @evmethods = evmethods.uniq
    else
      @evmethods = Evmethod.all
    end

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
          flash[:alert] = @lo.errors.full_messages
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
          flash[:alert] = @lo.errors.full_messages
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
