# encoding: utf-8

require 'restclient'
require 'json'
require 'base64'

def invokeApiMethod(url,obj)
	begin
		RestClient.post(
		  url,
		  obj.to_json,
		  :content_type => :json,
		  :accept => :json
		){
			|response|
			yield JSON(response),response.code
		}
	rescue => e
		puts "Exception: " + e.message
	end
end


#Add LO

params = Hash.new
params["utf8"] = "✓"
# Authentication
# params["authentication"] = 'Basic ' + Base64.encode64("name" + ':' + "password")
# params["authenticity_token"] = '';
params["name"] = "ViSH"
params["auth_token"] = "twCDn123Me84GH4sCDxkMg"
#LO
params["lo"] = Hash.new
params["lo"]["name"] = "Curiosity Flashcard"
params["lo"]["url"] = "http://vishub.org/excursions/83"
params["lo"]["repository"] = "ViSH"
params["lo"]["description"] = "A Flashcard about Curiosity, the car-sized robotic rover exploring Gale Crater on Mars."
params["lo"]["categories"] = ["Software Engineering", "Technology"]
params["lo"]["tag_list"] = "Biology,Chemistry,Maths"
#Need to be transformed to params["lo"]["language_id"]
params["lo"]["lanCode"] =  "en"
params["lo"]["lotype"] = "VE slideshow"
params["lo"]["technology"] = "HTML"
params["lo"]["hasText"] = "1"
params["lo"]["hasImages"] = "1"
params["lo"]["hasVideos"] = "0"
params["lo"]["hasAudios"] = "0"
params["lo"]["hasQuizzes"] = "0"
params["lo"]["hasWebs"] = "0"
params["lo"]["hasFlashObjects"] = "0"
params["lo"]["hasApplets"] = "0"
params["lo"]["hasDocuments"] = "0"
params["lo"]["hasFlashcards"] = "0"
params["lo"]["hasVirtualTours"] = "0"
params["lo"]["hasEnrichedVideos"] = "0"

invokeApiMethod('http://localhost:3000/api/v1/addLo/',params){ |response,code|
	if(code >= 400 and code <=500)
		puts "Error"
		puts "Response code: " + code.to_s
	else
		puts "Success"
	end
	
	puts response
}