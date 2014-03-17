class SurveysController < ApplicationController

  def index
    render "surveys"
  end

  def completed
  	render "completed"
  end

end
