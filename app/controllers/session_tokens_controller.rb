class SessionTokensController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :find_app_and_tokens, :only => [:index, :destroy_all, :destroy_all_expired]
  before_filter :find_token, :only => [:show, :edit, :update, :destroy]

  def index
    authorize! :show, @session_tokens
  end

  def show
   authorize! :show, @session_token
  end

  def new
    @app = App.find_by_id(params[:app_id]) unless params[:app_id].blank?
    if @app
      authorize! :update, @app
      @session_token = SessionToken.new({:app_id => @app.id})
      @los = @app.los
    else
      @session_token = SessionToken.new
      @los = Lo.all
    end

    actionParams = {}
    actionParams[:lo] = params[:lo_id] if params[:lo_id]
    actionParams[:evmethod] = params[:evmethod_id] if params[:evmethod_id]
    actionParams[:evmethod] = Utils.getEvMethods.first[1] if params[:link] and actionParams[:evmethod].blank?
    @session_token.assign_attributes({:action_params => actionParams.to_json}) unless actionParams.blank?

    authorize! :create, @session_token
    authorize! :show, @los

    respond_to do |format|
      format.html
      format.json { render json: @session_token }
    end
  end

  def create
    @session_token = SessionToken.new(params[:session_token])
    authorize! :create, @session_token

    respond_to do |format|
      if @session_token.save
        format.html {
          redirect_to (params[:link]==="true" ? session_token_path(@session_token) : app_path(@session_token.app)), notice: I18n.t("session_tokens.message.success.create") 
        }
        format.json { render json: @session_token, status: :created, location: @session_token }
      else
        format.html { 
          flash.now[:alert] = @session_token.errors.full_messages
          render action: "new"
        }
        format.json { render json: @session_token.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize! :update, @session_token
    @app = @session_token.app
    authorize! :update, @app
    @los = @app.los
    authorize! :show, @los

    respond_to do |format|
      format.html
      format.json { render json: @session_token }
    end
  end

  def update
    #Update action_params
    params[:session_token] ||= params[:session_token]
    params[:session_token][:action_params] ||= {}
    @session_token.assign_attributes(params[:session_token])
    authorize! :update, @session_token
    @session_token.valid?

    respond_to do |format|
      if @session_token.errors.blank? and @session_token.save
        format.html { redirect_to app_path(@session_token.app), notice: I18n.t("session_tokens.message.success.update") }
        format.json { render json: @session_token, status: :created, location: @session_token }
      else
        format.html { 
          flash.now[:alert] = @session_token.errors.full_messages
          render action: "edit"
        }
        format.json { render json: @session_token.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @session_token
    @session_token.destroy

    respond_to do |format|
      format.html { redirect_to app_path(@session_token.app), notice: I18n.t("session_tokens.message.success.destroy") }
      format.json { head :no_content }
    end
  end

  def destroy_all
    authorize! :destroy, @session_tokens
    @session_tokens.destroy_all
    redirect_to (@app.nil? ? session_tokens_path : app_path(@app))
  end

  def destroy_all_expired
    @session_tokens = @session_tokens.expired
    authorize! :destroy, @session_tokens
    @session_tokens.destroy_all
    redirect_to (@app.nil? ? session_tokens_path : app_path(@app))
  end


  private

  def find_app_and_tokens
    @app = App.find_by_id(params[:app_id]) unless params[:app_id].blank?
    unless @app.nil?
      @session_tokens = @app.session_tokens
    else
      @session_tokens = SessionToken.where(true)
    end
  end

  def find_token
    @session_token = SessionToken.find(params[:id])
  end

end
