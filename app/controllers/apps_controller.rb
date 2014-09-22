class AppsController < ApplicationController
  before_filter :authenticate_user!

  # GET /apps
  # GET /apps.json
  def index
    @apps = App.all(:order => 'name ASC')
    authorize! :index, @apps

    Utils.update_sessions_paths(session, request.url, nil)
    
    respond_to do |format|
      format.html
      format.json { render json: @apps }
    end
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
    @app = App.find(params[:id])
    authorize! :show, @app

    Utils.update_sessions_paths(session, apps_path, request.url)

    respond_to do |format|
      format.html
      format.json { render json: @app }
    end
  end

  # GET /apps/new
  # GET /apps/new.json
  def new
    @app = App.new
    authorize! :create, @app

    Utils.update_return_to(session,request)

    respond_to do |format|
      format.html
      format.json { render json: @app }
    end
  end

  # GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
    authorize! :edit, @app

    Utils.update_return_to(session,request)

    respond_to do |format|
      format.html
      format.json { render json: @app }
    end
  end

  # POST /apps
  # POST /apps.json
  def create
    @app = App.new(params[:app])
    authorize! :create, @app

    respond_to do |format|
      if @app.save 
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: I18n.t("applications.message.success.create") }
        format.json { render json: @app, status: :created, location: @app }
      else
        format.html { 
          flash.now[:alert] = @app.errors.full_messages
          render action: "new"
        }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /apps/1
  # PUT /apps/1.json
  def update
    @app = App.find(params[:id])
    authorize! :update, @app

    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: I18n.t("applications.message.success.update") }
        format.json { head :no_content }
      else
        format.html { 
          flash.now[:alert] = @app.errors.full_messages
          render action: "edit"
        }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @app = App.find(params[:id])
    authorize! :destroy, @app
    @app.destroy

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end

  # GET /apps/:id/create_session_token
  def create_session_token
    @app = App.find(params[:id])
    authorize! :update, @app

    @app.create_session_token
    
    respond_to do |format|
      format.html { redirect_to app_path(@app) }
      format.json { render json: @app }
    end
  end


  private

end
