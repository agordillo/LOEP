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

	def generic_back_link
    if iamAdmin?
      link_to 'Back', :back
    else
      link_to "Home", home_path 
    end
  end

	#Role helpers

	def iamAdmin?
		isAdmin?(current_user) || iamSuperAdmin?
	end

	def iamSuperAdmin?
		isSuperAdmin?(current_user)
	end

	def isAdmin?(user)
		checkRoleForUser(user,"Admin") || isSuperAdmin?(user)
	end

	def isSuperAdmin?(user)
		checkRoleForUser(user,"SuperAdmin")
	end

	def checkRoleForUser(user,role)
		!user.nil? and user.role?(role)
	end


end
