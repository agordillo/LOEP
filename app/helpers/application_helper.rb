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
	      link_to t("dictionary.back"), :back, :class => 'backLink'
	    else
	      link_to t("menu.home"), home_path, :class => 'backLink'
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

	def iamReviewer?
		isReviewer?(current_user)
	end

	def isReviewer?(user)
		checkRoleForUser(user,"Reviewer")
	end

	def checkRoleForUser(user,role)
		!user.nil? and user.role?(role)
	end

end
