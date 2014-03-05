# encoding: utf-8

namespace :fixes do
	task :assignmentsWithOneEvMethod => :environment do |t, args|
		puts "Fixing assignments"
		LORI15 = Evmethod.find_by_name("LORI v1.5");
		Assignment.all.each do |assignment| 
			if assignment.evmethod_id.nil?
				assignment.update_column :evmethod_id, LORI15.id;
			end

			#Completed_at
			if assignment.status=="Completed" and assignment.completed_at.nil? and !assignment.evaluation.nil?
				assignment.update_column :completed_at, assignment.evaluation.created_at;
			end
		end
	end
end

 