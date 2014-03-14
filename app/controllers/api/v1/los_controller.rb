class Api::V1::LosController < Api::V1::BaseController
  before_filter :authenticate_app
  before_filter :filterLOCategories, :only => [:create, :update]
  before_filter :filterLOLanguage, :only => [:create, :update]


  # API REST for LOs

  # GET /api/v1/los
  def index
    authorize! :show, current_app.los

    respond_to do |format|
      format.any {
        render json: current_app.los
      }
    end    
  end

  # GET /api/v1/los/:id
  def show
    lo = Lo.find(params[:id])
    authorize! :show, lo

    respond_to do |format|
      format.any {
        render json: lo
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
          render :json => @lo
        else
          render json: @lo.errors, status: :unprocessable_entity
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
            render json: lo 
          else
            render json: lo.errors, status: :unprocessable_entity
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
        render json: "Done"
      }
    end
  end


  private

  def filterLOCategories
    if params[:lo] and params[:lo][:categories]
      params[:lo][:categories] = params[:lo][:categories].reject{|c| c.empty? }.to_json
    end
  end

  def filterLOLanguage
    if params[:lo] and params[:lo][:lanCode]
      begin
      	params[:lo][:language_id] = Language.find_by_shortname(params[:lo][:lanCode]).id
      rescue
        params[:lo][:language_id] = Language.find_by_shortname("lanot").id
      end
      params[:lo].delete :lanCode
    else
      params[:lo][:language_id] = Language.find_by_shortname("lanot").id
    end
  end

end