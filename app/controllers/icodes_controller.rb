class IcodesController < ApplicationController
  before_filter :authenticate_admin!

  # GET /icodes/new
  # GET /icodes/new.json
  def new
    @icode = Icode.new
    authorize! :create, @icode

    respond_to do |format|
      format.html
      format.json { render json: @icode }
    end
  end

  # POST /icodes
  # POST /icodes.json
  def create
    @icode = Icode.new(params[:icode])
    authorize! :create, @icode

    respond_to do |format|
      if @icode.save
        format.html { redirect_to icode_path(@icode), notice: I18n.t("icodes.message.success.create") }
        format.json { render json: @icode, status: :created, location: @icode }
      else
        format.html { 
          flash.now[:alert] = @icode.errors.full_messages
          render action: "new"
        }
        format.json { render json: @icode.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /icode/:id
  # POST /icode/:id.json
  def show
    @icode = Icode.find(params[:id])
    authorize! :show, @icode

    respond_to do |format|
      format.html
      format.json{
        render :json => @icode
      }
    end
  end

  # DELETE /icodes/:id
  # DELETE /icodes/:id.json
  def destroy
    @icode = Icode.find(params[:id])
    authorize! :destroy, @icode

    @icode.destroy

    respond_to do |format|
      format.html { redirect_to home_path }
      format.json { head :no_content }
    end
  end

end
