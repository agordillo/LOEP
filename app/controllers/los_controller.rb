class LosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :filterCategories
  before_filter :getOptionsForSelect

  # GET /los
  # GET /los.json
  def index
    @los = Lo.all
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @los }
    end
  end

  # GET /los/1
  # GET /los/1.json
  def show
    @lo = Lo.find(params[:id])
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @lo }
    end
  end

  # GET /los/new
  # GET /los/new.json
  def new
    @lo = Lo.new
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @lo }
    end
  end

  # GET /los/1/edit
  def edit
    @lo = Lo.find(params[:id])
    @options_select = getOptionsForSelect
    respond_to do |format|
      format.html { render layout: "application_with_menu" }
      format.json { render json: @lo }
    end
  end

  # POST /los
  # POST /los.json
  def create
    @lo = Lo.new(params[:lo])
    @options_select = getOptionsForSelect
    respond_to do |format|
      if @lo.save
        format.html { redirect_to @lo, notice: 'Lo was successfully created.' }
        format.json { render json: @lo, status: :created, location: @lo }
      else
        format.html { 
          flash[:alert] = @lo.errors.full_messages
          render action: "new", :layout => "application_with_menu"
        }
        format.json { render json: @lo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /los/1
  # PUT /los/1.json
  def update
    @lo = Lo.find(params[:id])
    @options_select = getOptionsForSelect
    respond_to do |format|
      if @lo.update_attributes(params[:lo])
        format.html { redirect_to @lo, notice: 'Lo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { 
          flash[:alert] = @lo.errors.full_messages
          render action: "edit", :layout => "application_with_menu"
        }
        format.json { render json: @lo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /los/1
  # DELETE /los/1.json
  def destroy
    @lo = Lo.find(params[:id])
    @lo.destroy

    respond_to do |format|
      format.html { redirect_to los_url }
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

end
