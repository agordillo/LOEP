# encoding: utf-8

class Api::V1::LosController < Api::V1::BaseController
  before_filter :getLO, :only => [:show, :update, :destroy]
  before_filter :filterParams, :only => [:create, :update]

  # API REST for LOs

  # GET /api/v1/los
  def index
    authorize! :show, current_app.los

    respond_to do |format|
      format.any {
        render json: current_app.los.map{ |lo| lo.extended_attributes }, :content_type => "application/json"
      }
    end
  end

  # GET /api/v1/los/:id
  def show
    authorize! :show, @lo

    respond_to do |format|
      format.any {
        unless @lo.nil?
          render json: @lo.extended_attributes, :content_type => "application/json"
        else
          render json: {"error" => "Learning Object not found"}, status: :not_found, :content_type => "application/json"
        end
      }
    end
  end

  #Create or update a Learning Object in the LOEP Platform
  # POST /api/v1/los
  def create
    #Look for an existing Learning Object
    if params[:lo] and params[:lo][:repository] and params[:lo][:id_repository]
      @lo = Lo.where(:repository => params[:lo][:repository], :id_repository => params[:lo][:id_repository]).first
    end

    if @lo.nil?
      #Create new Learning Object
      @lo = Lo.new(params[:lo])
      authorize! :create, @lo

      @lo.app_id = current_app.id
      @lo.owner_id = current_app.user.id
    else
      @lo.assign_attributes(params[:lo])
      authorize! :update, @lo
    end

    @lo.valid?

    respond_to do |format|
      format.any { 
        if @lo.errors.blank? and @lo.save
          render :json => @lo.extended_attributes, :content_type => "application/json"
        else
          render json: @lo.errors, status: :bad_request, :content_type => "application/json"
        end 
      }
    end
  end

  # PUT /api/v1/los/:id
  def update
    @lo.assign_attributes(params[:lo])
    authorize! :update, @lo

    @lo.valid?

    respond_to do |format|
        format.any {
          if @lo.errors.blank? and @lo.save
            render json: @lo.extended_attributes, :content_type => "application/json"
          else
            render json: @lo.errors, status: :bad_request, :content_type => "application/json"
          end
        }
    end
  end

  # DELETE /api/v1/los/:id
  def destroy
    authorize! :destroy, @lo
    @lo.destroy

    respond_to do |format|
      format.any { 
        render json: "Done", :content_type => "application/json"
      }
    end
  end


  private

  def getLO
    return if params[:id].blank?
    query = {}
    query[:repository] = params["repository"] unless params["repository"].blank?
    if params[:use_id_loep].nil?
      query[:id_repository] = params[:id]
    else
      query[:id] = params[:id]
    end
    @lo = current_app.los.where(query).first
  end

  def filterParams
    return unless params[:lo]

    #Filter LO Language
    language = nil
    if params[:lo][:lanCode]
      language = Language.find_by_code(params[:lo][:lanCode])
      params[:lo].delete :lanCode
    end
    language = Language.find_by_code("lanot") if language.nil?
    params[:lo][:language_id] = language.id
  end

end