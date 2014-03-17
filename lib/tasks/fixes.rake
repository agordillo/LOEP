# encoding: utf-8

namespace :fixes do
	#How to use: bundle exec rake fixes:patchToV001
	#In production: bundle exec rake fixes:patchToV001 RAILS_ENV=production
	task :patchToV001 => :environment do |t, args|
		puts "Updating LOEP to VERSION 0.0.1"
		
		puts "Fixing Evaluations STI"
		Evaluation.update_all(:type => "Evaluations::Lori")
		LORI15 = Evmethod.find_by_name("LORI v1.5")
		LORI15.update_column :module, "Evaluations::Lori"

		Rake::Task["fixes:assignments"].invoke

		puts "Creating metrics"
		LORI15 = Evmethod.find_by_name("LORI v1.5")
		
		LORIAM = Metrics::LORIAM.new
		LORIAM.name = "LORI Arithmetic Mean"
		LORIAM.evmethods.push(LORI15);
		LORIAM.save

		LORIWAM = Metrics::LORIWAM.new
		LORIWAM.name = "LORI Weighted Arithmetic Mean"
		LORIWAM.evmethods.push(LORI15);
		LORIWAM.save

		puts "Creating LO scores for each Metric"
		Rake::Task["fixes:updateScores"].invoke

		puts "Adding new languages"
		#Create Languages
		lindependant = Language.new
		lindependant.name = "Language independent"
		lindependant.shortname = "lanin"
		lindependant.save

		lother = Language.new
		lother.name = "Other"
		lother.shortname = "lanot"
		lother.save

		italiano = Language.new
		italiano.name = "Italiano"
		italiano.shortname = "it"
		italiano.save

		puts "Fixing Web Apps"
		superAdmin = User.superAdmins.first
		if !superAdmin.nil?
			App.all.each do |app|
				if app.user_id.nil?
					app.update_column :user_id, superAdmin.id
				end
			end

			#LOs without owner
			adminApp = superAdmin.apps.first
			Lo.where(:owner_id => nil).each do |lo|
				lo.update_column :owner_id, superAdmin.id
				if !adminApp.nil?
					lo.update_column :app_id, adminApp.id
				end
			end
		end

		puts "Fixing Learning Objects"
		Lo.all.each do |lo|
			if lo.scope.nil? or !["Private", "Protected", "Public"].include? lo.scope
      			lo.update_column :scope, "Private"
    		end
		end

		puts "Updating finished"
	end

	task :assignments => :environment do |t, args|
		puts "Fixing assignments"

		LORI15 = Evmethod.find_by_name("LORI v1.5")

		Assignment.all.each do |assignment| 
			if assignment.evmethod_id.nil?
				assignment.update_column :evmethod_id, LORI15.id
			end

			#Completed_at
			if assignment.status=="Completed" and assignment.completed_at.nil? and !assignment.evaluations.empty?
				assignment.update_column :completed_at, assignment.evaluations.last.created_at
			end

			#Suitability
			if assignment.suitability.nil?
				assignment.update_column :suitability, MatchingSystem.getMatchingScore(assignment.lo,assignment.user)
			end
		end

		puts "Assignments fixed"
	end

	task :updateScores => :environment do |t, args|
		puts "Updating scores"
		Score.delete_all
		Metric.all.each do |m|
			Lo.all.each do |lo|
				s = Score.new
				s.metric_id = m.id
				s.lo_id = lo.id
				s.save
			end
		end
		puts "Updating scores finished"
	end

	task :setAssignmentsDeadlines => :environment do |t, args|
		puts "Set deadlines"
		Assignment.where(:deadline=>nil).each do |assignment|
			assignment.update_column :deadline, (DateTime.now - 1)
		end
	end

	task :fixViSHLOs => :environment do |t, args|
		puts "Fixing ViSH Learning Objects"

		puts "Add repository id field"
		Lo.where(:repository=>"ViSH", :id_repository=>nil).each do |lo|
			if !lo.url.nil?
				idRepository = lo.url.split("/").pop.to_i
				lo.update_column :id_repository, idRepository
			end
		end
	end
	
end

 