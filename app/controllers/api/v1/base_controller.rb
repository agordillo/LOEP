class Api::V1::BaseController < ActionController::Base
  before_filter :authenticate_app
  before_filter :filterLOCategories
  before_filter :filterLOLanguage

  def addLo
  	@lo = Lo.new(params[:lo])
  	# authorize! :create, @lo #API authentication lacks CanCan integration

  	respond_to do |format|
      format.json { 
      	if @lo.save
      		render :json => @lo
      	else
      		render json: @lo.errors, status: :unprocessable_entity
      	end 
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
      end
      params[:lo].delete :lanCode
    end
  end

  #Authentication filter
  def authenticate_app
    if params["name"].nil? or params["auth_token"].nil?
      render :json => ["Unauthorized"], :status => :unauthorized
    end
    app = App.find_by_name(params["name"])
    if app.nil? or app.auth_token != params["auth_token"]
      render :json => ["Unauthorized"], :status => :unauthorized
    end
  end

end