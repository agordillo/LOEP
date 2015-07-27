# encoding: utf-8

namespace :metadata do

	#How to use: bundle exec rake metadata:updateContext
	#In production: bundle exec rake metadata:updateContext RAILS_ENV=production
	task :updateContext => :environment do |t, args|
		puts "Updating metadata context"

		#Remove previous metadata records
		MetadataField.all.map{|mf| mf.destroy}

		Metadata.all.each do |metadataRecord|
			metadata_fields = metadataRecord.getMetadata({:fields => true})
			
			#Title
			unless metadata_fields["1.2"].blank?
				Metrics::LomMetadataConformance.processFreeText(metadata_fields["1.2"]).each do |key,value|
					mf = MetadataField.new({:name => "1.2", :field_type => "freetext", :value => key, :n => value, :metadata_id => metadataRecord.id})
					mf.save
				end
			end

			#Language
			unless metadata_fields["1.3"].blank?
				mf = MetadataField.new({:name => "1.3", :field_type => "categorical", :value => metadata_fields["1.3"], :n => 1, :metadata_id => metadataRecord.id})
				mf.save
			end

			#Description
			unless metadata_fields["1.4"].blank?
				Metrics::LomMetadataConformance.processFreeText(metadata_fields["1.4"]).each do |key,value|
					mf = MetadataField.new({:name => "1.4", :field_type => "freetext", :value => key, :n => value, :metadata_id => metadataRecord.id})
					mf.save
				end
			end

		end
	end

end

 