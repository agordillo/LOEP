class LoepNotifier

	def self.notifyLoUpdate(app,lo)
		if app.callback.nil? or app.auth_token.nil? or lo.id_repository.nil?
			return
		end

		basePath = app.callback
		if app.callback.last != "/"
			basePath = app.callback + "/"
		end
		appURI = URI(app.callback)

		#Build params
		params = Hash.new
		params["app_name"] = app.name
		params["auth_token"] = app.auth_token
		params["id_loep"] = lo.id
		params["id_repository"] = lo.id_repository
		params["lo"] = lo.extended_attributes.to_json

		host = appURI.host
		port = appURI.port
		path = appURI.path + "los/" + lo.id_repository.to_s

		req = Net::HTTP::Put.new(path,{'Content-Type' =>'application/json'})
		req.set_form_data(params)
		response = Net::HTTP.new(host, port).start {|http| http.request(req) }
	end

end
