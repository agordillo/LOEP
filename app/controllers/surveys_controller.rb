class SurveysController < ApplicationController
  before_filter :authenticate_user!

  def index
    :authenticate_user!
    render "surveys"
  end

end
