class Api::V1::BaseController < ActionController::Base
  before_filter :filterLOCategories
  before_filter :filterLOLanguage

  def addLo
  	@lo = Lo.new(params[:lo])
  	# authorize! :create, @lo

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

end