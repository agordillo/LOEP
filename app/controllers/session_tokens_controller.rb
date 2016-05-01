class SessionTokensController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @app = App.find_by_id(params[:app_id]) unless params[:app_id].blank?
    unless @app.nil?
      @session_tokens = @app.session_tokens
    else
      @session_tokens = SessionToken.all
    end 

    authorize! :show, @session_tokens
  end

  def new
    @session_token = SessionToken.new({:app_id => params[:app_id]})
    authorize! :create, @session_token

    respond_to do |format|
      format.html
      format.json { render json: @icode }
    end
  end

  def create
    @session_token = SessionToken.new(params[:session_token])
    authorize! :create, @session_token

    respond_to do |format|
      if @session_token.save
        format.html { redirect_to app_path(@session_token.app), notice: I18n.t("session_tokens.message.success.create") }
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

  def destroy
    @session_token = SessionToken.find(params[:id])
    authorize! :destroy, @session_token

    @session_token.destroy

    respond_to do |format|
      format.html { redirect_to app_path(@session_token.app), notice: I18n.t("session_tokens.message.success.destroy") }
      format.json { head :no_content }
    end
  end

  def destroy_all
    @app = App.find_by_id(params[:app_id]) unless params[:app_id].blank?
    unless @app.nil?
      @session_tokens = @app.session_tokens
    else
      @session_tokens = SessionToken
    end 
    authorize! :destroy, @session_tokens
    @session_tokens.destroy_all

    unless @app.nil?
      redirect_to app_path(@app)
    else
      redirect_to session_tokens_path
    end
  end

  def destroy_all_expired
    @app = App.find_by_id(params[:app_id]) unless params[:app_id].blank?
    unless @app.nil?
      @session_tokens = @app.session_tokens
    else
      @session_tokens = SessionToken
    end 
    @session_tokens = @session_tokens.expired
    authorize! :destroy, @session_tokens
    @session_tokens.destroy_all

    unless @app.nil?
      redirect_to app_path(@app)
    else
      redirect_to session_tokens_path
    end
  end

end
