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

	task :updateLOsFromMetadata => :environment do |t, args|
		puts "Updating LOs from Metadata"
		Metadata.all.each do |m|
			lo = m.lo
			metadataFields = m.getMetadata({:fields => true})
			#Title
			if !metadataFields["1.2"].blank? and metadataFieldNormalizeText(metadataFields["1.2"])!=metadataFieldNormalizeText(lo.name)
				lo.update_column :name, metadataFields["1.2"]
			end
			#Description
			if !metadataFields["1.4"].blank? and metadataFieldNormalizeText(metadataFields["1.4"])!=metadataFieldNormalizeText(lo.description)
				lo.update_column :description, metadataFields["1.4"]
			end
			#Language
			if !metadataFields["1.3"].blank? and metadataFields["1.3"]!=lo.language.code
				language = Language.find_by_code(metadataFields["1.3"])
				lo.update_column :language_id, language.id unless language.blank?
			end
		end
	end

	def metadataFieldNormalizeText(str)
		str.gsub(/([\n|\r])/,"") if str.is_a? String
	end
end