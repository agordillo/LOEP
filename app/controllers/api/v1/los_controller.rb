# encoding: utf-8

class Api::V1::LosController < Api::V1::BaseController
  before_filter :filterLOLanguage, :only => [:create, :update]

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
    if params[:use_id_loep].nil?
      lo = current_app.los.find_by_id_repository(params[:id])
    else
      lo = current_app.los.find_by_id(params[:id])
    end
    authorize! :show, lo

    respond_to do |format|
      format.any {
        unless lo.nil?
          render json: lo.extended_attributes, :content_type => "application/json"
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

    if @lo.scope.nil? or !["Private", "Protected", "Public"].include? @lo.scope
      @lo.scope = "Private"
    end

    if @lo.lotype.nil? or !I18n.t("los.types").map{|k,v| k.to_s}.include? @lo.lotype
      @lo.lotype = "unspecified"
    end

    if @lo.technology.nil? or !I18n.t("los.technology_or_format").map{|k,v| k.to_s}.include? @lo.technology
      @lo.technology = "unspecified"
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
    lo = Lo.find(params[:id])
    authorize! :update, lo

    respond_to do |format|
        format.any { 
          if lo.update_attributes(params[:lo])
            render json: lo.extended_attributes, :content_type => "application/json"
          else
            render json: lo.errors, status: :bad_request, :content_type => "application/json"
          end
        }
    end
  end

  # DELETE /api/v1/los/:id
  def destroy
    lo = Lo.find(params[:id])
    authorize! :destroy, lo
    lo.destroy

    respond_to do |format|
      format.any { 
        render json: "Done", :content_type => "application/json"
      }
    end
  end


  private

  def filterLOLanguage
    if params[:lo]
      if params[:lo][:lanCode]
        begin
        	params[:lo][:language_id] = Language.find_by_code(params[:lo][:lanCode]).id
        rescue
          params[:lo][:language_id] = Language.find_by_code("lanot").id
        end
        params[:lo].delete :lanCode
      else
        params[:lo][:language_id] = Language.find_by_code("lanot").id
      end
    end
  end

end