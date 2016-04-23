# Set up additional LOEP settings
# Store some variables in configuration to speed things up
# Config accesible in LOEP::Application::config

LOEP::Application.configure do
  config.after_initialize do

    #Keep some data on config to speed up Metadata quality metrics and TFIDF calculations

    if ActiveRecord::Base.connection.table_exists?('metadata_fields') and ActiveRecord::Base.connection.table_exists?('grouped_metadata_fields')
      
      #Get all repositories (nil means all repositories)
      # repositories = (MetadataField.all.map{|mf| mf.repository} + [nil]).uniq
      repositories = (Lo.all.map{|lo| lo.repository} + [nil]).uniq

      #Initial values
      total_entries = {}
      categorical_fields = {}
      words = {}
      max_graph_links = {}

      conformanceItems = Metrics::LomMetadataConformance.conformanceItems
      categoricalFields = conformanceItems.select{|k,v| v[:type]=="categorical"}
      freeTextFields = conformanceItems.select{|k,v| v[:type]=="freetext"}

      repositories.each do |repository|
        unless repository.nil?
          total_entries[repository] = [1,Lo.where(:repository => repository).count].max
        else
          total_entries[repository] = [1,Lo.all.count].max
        end

        allGroupedRepositoryMetadataInstances = GroupedMetadataField.where({:repository => repository})

        #Categorical fields for Conformance items
        categoricalFields.each do |key,value|
          groupedMetadataInstances = allGroupedRepositoryMetadataInstances.where({:name => key, :field_type => "categorical"})
          categorical_fields[repository] = {}
          categorical_fields[repository][key] = {}
          categorical_fields[repository][key + "_total"] = groupedMetadataInstances.find_by_value(nil).n rescue 1
          groupedMetadataInstances.map{|gm| gm.value}.each do |value|
            #Iterate over all values that this metadata field takes for this repository
            categorical_fields[repository][key][value] = groupedMetadataInstances.find_by_value(value.downcase).n rescue 0
          end
        end

        #Words for TFIDF
        allGroupedTextMetadataInstances = allGroupedRepositoryMetadataInstances.where({:field_type => "freetext"})
        words[repository] = {}

        allGroupedTextMetadataInstances.each do |gmf|
          words[repository][gmf.value] = 0 if words[repository][gmf.value].nil?
          words[repository][gmf.value] += [gmf.n,total_entries[repository]-1].min
        end

        #Graphs
        max_graph_links[repository] = MetadataField.getMax("metadataGraphLink",{:repository => repository})
      end

      #Metadata field fixed thresholds (max values)
      #Used in Metrics::LomMetadataConformance
      #A possible enhancement will be to recalculate this fields based on database records
      metadata_fields_max = {}
      metadata_fields_max["1.1.2"] = 1.5
      metadata_fields_max["1.2"] = 3.25
      metadata_fields_max["1.4"] = 5.5
      metadata_fields_max["1.5"] = 4.25

      config.repositories = repositories
      config.total_entries = total_entries
      config.categorical_fields = categorical_fields
      config.words = words
      config.max_graph_links = max_graph_links
      config.metadata_fields_max = metadata_fields_max
      config.max_text_length = 100
    end
  end
end