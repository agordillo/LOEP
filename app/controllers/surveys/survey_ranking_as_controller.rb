class Surveys::SurveyRankingAsController < ApplicationController

	def new
		@ranking = Surveys::SurveyRankingA.new
		respond_to do |format|
      		format.html
    	end
	end

	def create
		@ranking = Surveys::SurveyRankingA.new(params[:surveys_survey_ranking_as])

		respond_to do |format|
			format.any {
				if @ranking.save 
					flash[:notice] = 'Your answer was successfully stored.'
					redirect_to "/surveys/completed"
				else
					flash.now[:alert] = @loric.errors.full_messages
					render action: "new"
				end
			}
	    end
	end

end
