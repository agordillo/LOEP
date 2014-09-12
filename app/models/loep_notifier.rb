class LoepNotifier

	# Notify an app that a LO has new information available
	# Request example
	# PUT http://localhost:8080/loep/los/55?app_name=MyLORApp&auth_token=tokenOfMyLORApp
	def self.notifyLoUpdate(app,lo)
		if app.callback.blank? or app.auth_token.blank? or lo.id_repository.blank?
			return
		end

		basePath = app.callback
		if app.callback.last != "/"
			basePath = app.callback + "/"
		end
		appURI = URI(basePath)

		host = appURI.host
		port = appURI.port
		path = appURI.path + "los/" + lo.id_repository.to_s

		if host.blank?
			return
		end

		#Build params
		params = Hash.new
		params["app_name"] = app.name
		params["auth_token"] = app.auth_token
		params["id_loep"] = lo.id
		params["id_repository"] = lo.id_repository
		params["lo"] = lo.extended_attributes.to_json

		require 'thread'
		Thread.new {
			begin 
				req = Net::HTTP::Put.new(path,{'Content-Type' =>'application/json'})
				req.set_form_data(params)
				response = Net::HTTP.new(host, port).start {|http| http.request(req) }
				# puts response
			rescue Exception => e
				# puts e.message
			end
		}
	end

end
