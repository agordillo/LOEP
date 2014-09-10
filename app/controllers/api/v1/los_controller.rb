# encoding: utf-8

class Api::V1::LosController < Api::V1::BaseController
  before_filter :filterLOCategories, :only => [:create, :update]
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
      lo = Lo.find(params[:id])
    end
    authorize! :show, lo
    respond_to do |format|
      format.any {
        unless lo.nil?
          render json: lo.extended_attributes, :content_type => "application/json"
        else
          render json: {"error" => "Learning Object not found"}, :content_type => "application/json"
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

    respond_to do |format|
      format.any { 
        if @lo.save
          render :json => @lo.extended_attributes, :content_type => "application/json"
        else
          render json: @lo.errors, status: :unprocessable_entity, :content_type => "application/json"
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
            render json: lo.errors, status: :unprocessable_entity, :content_type => "application/json"
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

  def filterLOCategories
    if params[:lo] and params[:lo][:categories]
      if params[:lo][:categories].is_a? String
        if !params[:lo][:categories].blank?
          params[:lo][:categories] = [params[:lo][:categories]].to_json
        else
          params[:lo].delete [:categories]
        end       
      elsif params[:lo][:categories].is_a? Array
        params[:lo][:categories] = params[:lo][:categories].reject{|c| c.empty? }.to_json
      else
        params[:lo].delete [:categories]
      end
    end
  end

  def filterLOLanguage
    if params[:lo] and params[:lo][:lanCode]
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