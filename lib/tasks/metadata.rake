# encoding: utf-8

namespace :metadata do

	#How to use: bundle exec rake metadata:updateContext
	#In production: bundle exec rake metadata:updateContext RAILS_ENV=production
	task :updateContext => :environment do |t, args|
		puts "Updating metadata context"

		#Remove previous metadata records
		MetadataField.all.map{|mf| mf.destroy}

		#Get conformance items
		conformanceItems = Metrics::LomMetadataConformance.conformanceItems

		Metadata.all.each do |metadataRecord|
			metadata_fields = metadataRecord.getMetadata({:fields => true})
			conformanceItems.each do |key,value|
				case conformanceItems[key][:type]
				when "freetext"
					generateFreeTextMetadataField(key,metadata_fields[key],metadataRecord)
				when "categorical"
					generateCategoricalMetadataField(key,metadata_fields[key],metadataRecord)
				end
			end
		end
	end

	def generateFreeTextMetadataField(metadataKey,metadataValue,metadataRecord)
		unless metadataValue.blank?
			Metrics::LomMetadataConformance.processFreeText(metadataValue).each do |key,value|
				mf = MetadataField.new({:name => metadataKey, :field_type => "freetext", :value => key, :n => value, :metadata_id => metadataRecord.id})
				mf.save
			end
		end
	end

	def generateCategoricalMetadataField(metadataKey,metadataValue,metadataRecord)
		unless metadataValue.blank?
			mf = MetadataField.new({:name => metadataKey, :field_type => "categorical", :value => metadataValue, :n => 1, :metadata_id => metadataRecord.id})
			mf.save
		end
	end

end

 