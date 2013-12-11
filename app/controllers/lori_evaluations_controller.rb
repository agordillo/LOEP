class LoriEvaluationsController < ApplicationController

  def new
    @lo = Lo.find(params[:lo_id])
    authorize! :rshow, @lo

    moduleName = self.controller_name.camelcase[0..self.controller_name.camelcase.length-2]
    @evmethod = Evmethod.find_by_module(moduleName)

    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
    else
      #Inferred
      @assignment = (@lo.assignments.where(:user_id => current_user.id).reject { |as| !as.evmethods.include? @evmethod }).first
    end
    authorize! :rshow, @assignment

    @evaluation = LoriEvaluation.new
    respond_to do |format|
      format.html
      format.json { render json: @evaluation }
    end
  end

end
