# encoding: utf-8

class Api::V1::LosController < Api::V1::BaseController
  before_filter :getLO, :only => [:show, :update, :destroy, :showEvaluationsRepresentation]
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

  # POST /api/v1/los
  def create
    @lo = Lo.new(params[:lo])
    authorize! :create, @lo

    @lo.app_id = current_app.id
    @lo.owner_id = current_app.user.id

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
    authorize! :update, @lo

    respond_to do |format|
        format.any { 
          if @lo.update_attributes(params[:lo])
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
    if params[:use_id_loep].nil?
      @lo = current_app.los.find_by_id_repository(params[:id])
    else
      @lo = current_app.los.find_by_id(params[:id])
    end
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