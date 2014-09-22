module AppHelper
	def app_new_session_token_path(app)
		return '/apps/' + app.id.to_s + '/create_session_token'
	end
end
