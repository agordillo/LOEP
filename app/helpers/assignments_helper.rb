module AssignmentsHelper

	def new_assignment_path_for(lo_ids,user_ids)
		path = new_assignment_path + "?"

		if !lo_ids.nil? and !lo_ids.is_a? Array
			lo_ids = [].push(lo_ids)
		end
		if !user_ids.nil? and !user_ids.is_a? Array
			user_ids = [].push(user_ids)
		end

		if !lo_ids.nil?
			path = path + "lo_ids="
			lo_ids.each_with_index do |lo_id,i|
				if i !=0
					path = path + ","
				end
				path = path + lo_id.to_s
			end
		end

		if !user_ids.nil?
			if !lo_ids.nil?
				path = path + "&"
			end
			path = path + "user_ids="
			user_ids.each_with_index do |user_id,i|
				if i !=0
					path = path + ","
				end
				path = path + user_id.to_s
			end
		end
		path
	end

	def loep_asignments_path
		if current_user.role?("Admin")
			assignments_path
		else
			"/rassignments"
		end
	end
	
end
