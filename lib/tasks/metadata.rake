# encoding: utf-8

namespace :metadata do

	#How to use: bundle exec rake metadata:updateContext
	#In production: bundle exec rake metadata:updateContext RAILS_ENV=production
	task :updateContext => :environment do |t, args|
		puts "Updating metadata context"

		#Remove previous metadata records
		MetadataField.all.map{|mf| mf.destroy}
		GroupedMetadataField.all.map{|gmf| gmf.destroy}

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

		#Create grouped metadata fields
		repositories = MetadataField.all.map{|mf| mf.repository}.uniq
		conformanceItems.each do |key,value|
			if conformanceItems[key][:type] == "freetext"
				metadataFields = MetadataField.where(:name => key)
				repositories.each do |repository|
					metadataFieldsOfRepository = metadataFields.where(:repository => repository)
					#Store the total number of resources that have defined a value for this key/repository pair.
					nTotal = metadataFieldsOfRepository.map{|m| m.metadata_id}.uniq.length
					if nTotal > 0
						g = GroupedMetadataField.new({:name => key, :field_type => "freetext", :repository => repository, :value => nil, :n => nTotal})
						g.save!
					end
					#Values. Store the total number of each value for this key/repository pair.
					values = metadataFieldsOfRepository.map{|m| m.value}.uniq
					values.each do |value|
						n = metadataFieldsOfRepository.where(:value => value).map{|m| m.metadata_id}.uniq.length
						if n > 0
							g = GroupedMetadataField.new({:name => key, :field_type => "freetext", :repository => repository, :value => value, :n => n})
							g.save!
						end
					end
				end
			end
		end
	end

	def generateFreeTextMetadataField(metadataKey,metadataValue,metadataRecord)
		unless metadataValue.blank?
			Metrics::LomMetadataConformance.processFreeText(metadataValue).each do |word,occurrences|
				mf = MetadataField.new({:name => metadataKey, :field_type => "freetext", :value => word, :n => occurrences, :metadata_id => metadataRecord.id})
				mf.save!
			end
		end
	end

	def generateCategoricalMetadataField(metadataKey,metadataValue,metadataRecord)
		unless metadataValue.blank?
			mf = MetadataField.new({:name => metadataKey, :field_type => "categorical", :value => metadataValue, :n => 1, :metadata_id => metadataRecord.id})
			mf.save!
		end
	end

end

 