# encoding: utf-8

namespace :fixes do
	#How to use: bundle exec rake fixes:updateScores
	#In production: bundle exec rake fixes:updateScores RAILS_ENV=production
	task :updateScores => :environment do |t, args|
		puts "Updating scores"
		Score.delete_all
		Metric.allc.each do |m|
			Lo.all.each do |lo|
				s = Score.new
				s.metric_id = m.id
				s.lo_id = lo.id
				s.save
			end
		end
		Rake::Task["fixes:updateAutomaticScores"].invoke
	end

	#How to use: bundle exec rake fixes:updateAutomaticScores
	#In production: bundle exec rake fixes:updateAutomaticScores RAILS_ENV=production
	task :updateAutomaticScores => :environment do |t, args|
		puts "Updating automatic scores..."
		Evmethod.allc_automatic.each do |evmethod|
			Lo.all.each do |lo|
				evmethod.getEvaluationModule.createAutomaticEvaluation(lo)
			end
		end
	end

	task :setAssignmentsDeadlines => :environment do |t, args|
		puts "Set deadlines"
		Assignment.where(:deadline=>nil).each do |assignment|
			assignment.update_column :deadline, (DateTime.now - 1)
		end
	end

	task :fixViSHLOs => :environment do |t, args|
		puts "Fixing ViSH Learning Objects"
		puts "Fix repository id field"

		Lo.where(:repository=>"ViSH").each do |lo|
			unless lo.url.nil?
				id = lo.url.split("/").pop
				idRepository = "Excursion:" + id
				lo.update_column :id_repository, idRepository
			end
		end
	end

	task :updateViSHLOsMetadata => :environment do |t, args|
		puts "Updating metadata of ViSH Learning Objects"

		Lo.where(:repository=>["ViSH","EducaInternet"]).each do |lo|
			unless lo.url.nil?
				if lo.metadata_url.blank?
					lo.update_column :metadata_url, lo.url + "/metadata.xml"
				end
				lo.update_metadata
			end
		end
	end

	task :rolesValue => :environment do
		roles = [
			{name:"SuperAdmin", value:9},
			{name:"Admin", value:8},
			{name:"Reviewer", value:2},
			{name:"User", value:1}
		]
		roles.each do |role|
			r = Role.find_by_name(role[:name])
			unless r.nil?
				puts "Updating role: " + role[:name]
				r.value = role[:value]
				r.save!
			end
		end
	end

end

 