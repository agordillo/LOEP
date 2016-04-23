# Set up additional LOEP settings
# Store some variables in configuration to speed things up
# Config accesible in LOEP::Application::config

LOEP::Application.configure do
  config.after_initialize do

    # #Keep words in the configuration
    # words = {}
    # if ActiveRecord::Base.connection.table_exists?('words')
    #   Word.where("occurrences > ?",5).first(5000000).each do |word|
    #     words[word.value] = [word.occurrences,config.repository_total_entries-1].min
    #   end
    # end
    # config.words = words

    #Keep some data on config to speed up Metadata quality metrics and TFIDF calculations

    #Categorical fields
    if ActiveRecord::Base.connection.table_exists?('metadata_fields') and ActiveRecord::Base.connection.table_exists?('grouped_metadata_fields')
      categorical_fields = {}

      #Get all repositories (nil means all repositories)
      # repositories = (MetadataField.all.map{|mf| mf.repository} + [nil]).uniq
      repositories = (Lo.all.map{|lo| lo.repository} + [nil]).uniq

      #Get conformance items
      conformanceItems = Metrics::LomMetadataConformance.conformanceItems
      categoricalFields = conformanceItems.select{|k,v| v[:type]=="categorical"}
      repositories.each do |repository|
        categoricalFields.each do |key,value|
          allGroupedMetadataInstances = GroupedMetadataField.where({:name => key, :field_type => "categorical", :repository => repository})
          categorical_fields[repository] = {}
          categorical_fields[repository][key] = {}
          categorical_fields[repository][key + "_total"] = allGroupedMetadataInstances.find_by_value(nil).n rescue 1
          allGroupedMetadataInstances.map{|gm| gm.value}.each do |value|
            #Iterate over all values that this metadata field takes for this repository
            categorical_fields[repository][key][value] = allGroupedMetadataInstances.find_by_value(value.downcase).n rescue 0
          end
        end
      end

      config.repositories = repositories
      config.categorical_fields = categorical_fields
    end
  end
end