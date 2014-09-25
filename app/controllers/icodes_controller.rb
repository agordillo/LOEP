class IcodesController < ApplicationController
  before_filter :authenticate_admin!

  # GET /icodes/new
  # GET /icodes/new.json
  def new
    @icode = Icode.new
    authorize! :create, @icode

    Utils.update_return_to(session,request)

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
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: I18n.t("icodes.message.success.create") }
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

end
