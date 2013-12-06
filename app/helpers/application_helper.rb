module ApplicationHelper
	def devise_mapping
	  Devise.mappings[:user]
	end

	def resource_name
	  devise_mapping.name
	end

	def resource_class
	  devise_mapping.to
	end

	def home_path
		if user_signed_in?
			return "/home"
		else
			return "/"
		end
	end
end
