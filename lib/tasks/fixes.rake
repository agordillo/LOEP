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
		puts "Fix repository id field"

		Lo.where(:repository=>"ViSH").each do |lo|
			unless lo.url.nil?
				id = lo.url.split("/").pop
				idRepository = "Excursion:" + id
				lo.update_column :id_repository, idRepository
			end
		end
	end

end

 