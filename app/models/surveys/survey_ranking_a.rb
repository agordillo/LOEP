# encoding: UTF-8

class Surveys::SurveyRankingA < ActiveRecord::Base
  attr_accessible :results
  validates :results, :presence => true

  def self.getSurveyLos
		@los = Hash.new

		@los[1] = Hash.new
		@los[1]["title"] = "Introducción al Péndulo Simple"
		@los[1]["url"] = "http://vishub.org/excursions/832"
		@los[1]["avatar"] = "http://vishub.org/pictures/3663.png"
		@los[1]["avgscore"] = 0
		@los[1]["avgranking"] = 0

		@los[2] = Hash.new
		@los[2]["title"] = "Introducción al Análisis de Circuitos"
		@los[2]["url"] = "http://vishub.org/excursions/659"
		@los[2]["avatar"] = "http://vishub.org/pictures/2876.jpeg"
		@los[2]["avgscore"] = 0
		@los[2]["avgranking"] = 0
		  
		@los[3] = Hash.new
		@los[3]["title"] = "Agujeros Negros"
		@los[3]["url"] = "http://vishub.org/excursions/613"
		@los[3]["avatar"] = "http://vishub.org//system/pdfexes/attaches/000/000/191/original/Agujeros_negros_CS5-0.jpg"
		@los[3]["avgscore"] = 0
		@los[3]["avgranking"] = 0

		@los[4] = Hash.new
		@los[4]["title"] = "¿Sabes a qué temperatura se evapora el O2? ¿el argón? ¿y el agua?"
		@los[4]["url"] = "http://vishub.org/excursions/390"
		@los[4]["avatar"] = "http://ciencias.buenconsejoicod.com/wp-content/uploads/2011/10/los-tres-estados-de-la-materia.gif"
		@los[4]["avgscore"] = 0
		@los[4]["avgranking"] = 0

		@los[5] = Hash.new
		@los[5]["title"] = "Juguemos con la Física en la Casa de las Ciencias"
		@los[5]["url"] = "http://vishub.org/excursions/655"
		@los[5]["avatar"] = "http://mc2coruna.org/img/plano-casa-gl.jpg"
		@los[5]["avgscore"] = 0
		@los[5]["avgranking"] = 0

		@los[6] = Hash.new
		@los[6]["title"] = "Movimiento Rectilíneo Uniforme"
		@los[6]["url"] = "http://vishub.org/excursions/503"
		@los[6]["avatar"] = "http://vishub.org/pictures/1562.gif"
		@los[6]["avgscore"] = 0
		@los[6]["avgranking"] = 0

		@los[7] = Hash.new
		@los[7]["title"] = "Medida del tiempo de reacción"
		@los[7]["url"] = "http://vishub.org/excursions/458"
		@los[7]["avatar"] = "http://vishub.org/pictures/1214.jpg"
		@los[7]["avgscore"] = 0
		@los[7]["avgranking"] = 0

		@los[8] = Hash.new
		@los[8]["title"] = "Estructura del Sistema Nervioso Humano"
		@los[8]["url"] = "http://vishub.org/excursions/631"
		@los[8]["avatar"] = "http://vishub.org//system/pdfexes/attaches/000/000/207/original/sistemanerviosohub-0.jpg"
		@los[8]["avgscore"] = 0
		@los[8]["avgranking"] = 0

		@los[9] = Hash.new
		@los[9]["title"] = "La mujer, innovadora de la ciencia"
		@los[9]["url"] = "http://vishub.org/excursions/536"
		@los[9]["avatar"] = "http://vishub.org/pictures/2073.png"
		@los[9]["avgscore"] = 0
		@los[9]["avgranking"] = 0

		@los[10] = Hash.new
		@los[10]["title"] = "Tipos de procariotas"
		@los[10]["url"] = "http://vishub.org/excursions/600"
		@los[10]["avatar"] = "http://www.vishub.org/pictures/2317.jpeg"
		@los[10]["avgscore"] = 0
		@los[10]["avgranking"] = 0

		@los[11] = Hash.new
		@los[11]["title"] = "Paramecium"
		@los[11]["url"] = "http://vishub.org/excursions/602"
		@los[11]["avatar"] = "http://vishub.org/assets/logos/original/excursion-08.png"
		@los[11]["avgscore"] = 0
		@los[11]["avgranking"] = 0

		@los[12] = Hash.new
		@los[12]["title"] = "Mi primera página"
		@los[12]["url"] = "http://vishub.org/excursions/629"
		@los[12]["avatar"] = "http://vishub.org/assets/logos/original/excursion-55.png"
		@los[12]["avgscore"] = 0
		@los[12]["avgranking"] = 0

		@los
	end

	def self.getResults
  	# Example of the results field
  	# JSON(Surveys::SurveyRankingA.last.results)
		# => {"los"=>
		#   {"7"=>{"score"=>"3", "ranking"=>7},
		#    "4"=>{"score"=>"7", "ranking"=>5},
		#    "1"=>{"score"=>"10", "ranking"=>1},
		#    "3"=>{"score"=>"9", "ranking"=>3},
		#    "6"=>{"score"=>"6", "ranking"=>2},
		#    "8"=>{"score"=>"8", "ranking"=>8},
		#    "5"=>{"score"=>"8", "ranking"=>6},
		#    "11"=>{"score"=>"2", "ranking"=>10},
		#    "10"=>{"score"=>"1", "ranking"=>9},
		#    "9"=>{"score"=>"4", "ranking"=>12},
		#    "2"=>{"score"=>"9", "ranking"=>4},
		#    "12"=>{"score"=>"0", "ranking"=>11}},
		#  "ranking"=>[1, 6, 3, 2, 4, 5, 7, 8, 10, 11, 12, 9]}

		los = getSurveyLos
		loCount = 0

		Surveys::SurveyRankingA.all.each do |survey|
			surveyResult = JSON(survey.results)

			if surveyResult["los"].blank?
				next
			end

			breakIteration = false

			12.times do |i|
				loInfo = surveyResult["los"][(i+1).to_s]
				if loInfo.blank? or loInfo["score"].blank? or loInfo["ranking"].blank?
					breakIteration = true
					break
				end
			end

			if breakIteration
				next
			end

			#Only completed surveys reach this point...
			12.times do |i|
				index = i+1
				loInfo = surveyResult["los"][index.to_s]
				los[index]["avgscore"] = los[index]["avgscore"] + loInfo["score"].to_i
				los[index]["avgranking"] = los[index]["avgranking"] + loInfo["ranking"].to_i
			end

			loCount = loCount +1
		end

		if loCount > 0
			12.times do |i|
				index = i+1
				los[index]["avgscore"] = los[index]["avgscore"]/loCount.to_f
				los[index]["avgranking"] = los[index]["avgranking"]/loCount.to_f
			end
		end

		los
  end

  def self.getRanking
  	los = getResults

  	los = los.sort { |loA,loB|
  		loA = loA[1]
  		loB = loB[1]

  		if loA["avgranking"] === loB["avgranking"]
  			loB["avgscore"] <=> loA["avgscore"]
  		else
  			loA["avgranking"] <=> loB["avgranking"]
  		end
  	}
  end

  def self.getNumericRanking
  	getRanking.map{ |lo| lo[0] }
  end

  def extended_attributes
  	attrs = Hash.new
  	surveyResult = JSON(self.results)["los"]
  	12.times do |i|
  		i = i+1
  		attrs["Score_LO" + i.to_s] = surveyResult[i.to_s]["score"]
  		attrs["Ranking_LO" + i.to_s] = surveyResult[i.to_s]["ranking"]
  	end
  	attrs
  end

end
