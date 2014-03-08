# encoding: utf-8

namespace :fixes do
	#How to use: bundle exec rake fixes:patchToV001
	task :patchToV001 => :environment do |t, args|
		puts "Updating LOEP to VERSION 0.0.1"
		Rake::Task["fixes:assignments"].invoke

		puts "Fixing Evaluations STI"
		Evaluation.update_all(:type => "Evaluations::Lori")
		LORI15 = Evmethod.find_by_name("LORI v1.5")
		LORI15.update_column :module, "Evaluations::Lori"

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
			if assignment.status=="Completed" and assignment.completed_at.nil? and !assignment.evaluation.nil?
				assignment.update_column :completed_at, assignment.evaluation.created_at
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
	
end

 