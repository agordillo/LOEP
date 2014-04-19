# encoding: UTF-8

class Surveys::SurveyRankingAsController < ApplicationController
	def new
		@ranking = Surveys::SurveyRankingA.new

		@los = Surveys::SurveyRankingA.getSurveyLos

		#Shuffle LOs
		@los = Hash[@los.to_a.shuffle]

		respond_to do |format|
      		format.html{
      			render :layout => "application_without_menu"
      		} 
    	end
	end

	def create
		if params[:ranking].blank? or params[:surveys_survey_ranking_as].blank?
			flash.now[:alert] = "La encuesta está incompleta"
			render action: "new"
			return
		end
		
		results = Hash.new
		results["los"] = Hash.new
		results["ranking"] = JSON(params[:ranking])

		params[:surveys_survey_ranking_as].each do |key, value|
			results["los"][key] = Hash.new
			results["los"][key]["score"] = value
			results["ranking"].each_with_index do |loid,index|
				if loid === key.to_i
					results["los"][key]["ranking"] = index+1
				end
			end
		end

		results = results.to_json
		@ranking = Surveys::SurveyRankingA.new({:results => results})

		respond_to do |format|
			format.any {
				if @ranking.save
					flash.now[:notice] = 'Tu respuesta se ha guardado correctamente. Muchas gracias por tu colaboración.'
					render "/surveys/completed", :layout => "application_without_menu"
				else
					flash.now[:alert] = @ranking.errors.full_messages
					render action: "new"
				end
			}
	    end
	end

	#Results
	def index
		if current_user.nil? or !current_user.isAdmin?
			return redirect_to home_path
		end
		@results = Surveys::SurveyRankingA.all
		@los = Surveys::SurveyRankingA.getRanking

		respond_to do |format|
		  format.html {
		  	render "results"
		  }
		  format.xlsx {
		  	@resources = @results
            @resourceName = "SurveyRankingResults"
		    render :xlsx => "results", :filename => "SurveyRankingA_Results.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
		  }
		  format.json { 
		    format.json { render json: @results.map{ |r| r.getAttributes } }
		  }
		end
	end

end
