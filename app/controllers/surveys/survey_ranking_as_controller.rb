# encoding: UTF-8

class Surveys::SurveyRankingAsController < ApplicationController

	def new
		@ranking = Surveys::SurveyRankingA.new

		@los = Hash.new

		@los[1] = Hash.new
		@los[1]["title"] = "Introducción al Péndulo Simple"
		@los[1]["url"] = "http://vishub.org/excursions/832"
		@los[1]["avatar"] = "http://vishub.org/pictures/3663.png"

		@los[2] = Hash.new
		@los[2]["title"] = "Introducción al Análisis de Circuitos"
		@los[2]["url"] = "http://vishub.org/excursions/659"
		@los[2]["avatar"] = "http://vishub.org/pictures/2876.jpeg"
		  
		@los[3] = Hash.new
		@los[3]["title"] = "Agujeros Negros"
		@los[3]["url"] = "http://vishub.org/excursions/613"
		@los[3]["avatar"] = "http://vishub.org//system/pdfexes/attaches/000/000/191/original/Agujeros_negros_CS5-0.jpg"

		@los[4] = Hash.new
		@los[4]["title"] = "¿Sabes a qué temperatura se evapora el O2? ¿el argón? ¿y el agua?"
		@los[4]["url"] = "http://vishub.org/excursions/390"
		@los[4]["avatar"] = "http://ciencias.buenconsejoicod.com/wp-content/uploads/2011/10/los-tres-estados-de-la-materia.gif"

		@los[5] = Hash.new
		@los[5]["title"] = "Juguemos con la Física en la Casa de las Ciencias"
		@los[5]["url"] = "http://vishub.org/excursions/655"
		@los[5]["avatar"] = "http://mc2coruna.org/img/plano-casa-gl.jpg"

		@los[6] = Hash.new
		@los[6]["title"] = "Movimiento Rectilíneo Uniforme"
		@los[6]["url"] = "http://vishub.org/excursions/503"
		@los[6]["avatar"] = "http://vishub.org/pictures/1562.gif"

		@los[7] = Hash.new
		@los[7]["title"] = "Medida del tiempo de reacción"
		@los[7]["url"] = "http://vishub.org/excursions/458"
		@los[7]["avatar"] = "http://vishub.org/pictures/1214.jpg"

		@los[8] = Hash.new
		@los[8]["title"] = "Estructura del Sistema Nervioso Humano"
		@los[8]["url"] = "http://vishub.org/excursions/631"
		@los[8]["avatar"] = "http://vishub.org//system/pdfexes/attaches/000/000/207/original/sistemanerviosohub-0.jpg"

		@los[9] = Hash.new
		@los[9]["title"] = "La mujer, innovadora de la ciencia"
		@los[9]["url"] = "http://vishub.org/excursions/536"
		@los[9]["avatar"] = "http://vishub.org/pictures/2073.png"

		@los[10] = Hash.new
		@los[10]["title"] = "Tipos de procariotas"
		@los[10]["url"] = "http://vishub.org/excursions/600"
		@los[10]["avatar"] = "http://www.vishub.org/pictures/2317.jpeg"

		@los[11] = Hash.new
		@los[11]["title"] = "Paramecium"
		@los[11]["url"] = "http://vishub.org/excursions/602"
		@los[11]["avatar"] = "http://vishub.org/assets/logos/original/excursion-08.png"

		@los[12] = Hash.new
		@los[12]["title"] = "Mi primera página"
		@los[12]["url"] = "http://vishub.org/excursions/629"
		@los[12]["avatar"] = "http://vishub.org/assets/logos/original/excursion-55.png"

		#Shuffle LOs
		@los = Hash[@los.to_a.shuffle]

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
