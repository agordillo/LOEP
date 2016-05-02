module SessionTokensHelper
	def action_class(s)
		case s.action
		when "evaluate"
			return "glyphicon glyphicon-star-empty"
		when "showchart"
			return "glyphicon glyphiconfull charts"
		else
			return "glyphicon glyphiconfull flash"
		end
	end

	def link_session_token_path(s)
		edit_session_token_path(s).gsub("edit","link")
	end

	def destroy_all_session_token_path(app_id=nil)
		path = "/session_tokens/destroy_all"
		path += "?app_id=" + app_id.to_s unless app_id.blank?
		path
	end

	def destroy_all_expired_session_token_path(app_id=nil)
		path = "/session_tokens/destroy_all_expired"
		path += "?app_id=" + app_id.to_s unless app_id.blank?
		path
	end
end