class Metadata::Lom < Metadata

  class << self

    def compliant?(xmlDoc)
      return false unless xmlDoc.is_a? Nokogiri::XML::Document
      lom = xmlDoc.at_xpath('//lom') rescue nil
      lom = xmlDoc.root if (lom.nil? and xmlDoc.root.name == "lom") rescue nil
      return false unless lom.is_a? Nokogiri::XML::Element
      # return false unless lom.attributes.is_a? Hash
      # return false unless lom.attributes["xmlns"].is_a? Nokogiri::XML::Attr
      # return false unless lom.attributes["xmlns"].value.include? "LOM"
      true
    end

    def getContent(xmlDoc)
      xmlDoc.at_xpath('//lom')
    end

    def schema
      "LOMv1.0"
    end

    def metadata_json(metadataRecord)
      metadataJSON = JSON.parse(metadataRecord.lom_content)["lom"] rescue {}
      metadataJSON = {} if metadataJSON.blank?
      return metadataJSON
    end

    #Build compliant JSON from original JSON
    def build_metadata_json(metadataJSON)
      Hash.from_xml_with_attributes(metadata_xml_from_json(metadataJSON["lom"])) rescue {}
    end

    def metadata_fields(metadataRecord)
      metadata_fields_from_json(metadata_json(metadataRecord))
    end

    def metadata_fields_from_json(metadataJSON={})
      fields = {}
      metadata = JSON.parse(metadataJSON.to_json) rescue {} #Deep copy
      metadata = {} unless metadata.is_a? Hash
      #Category 1
      unless metadata["general"].nil?
        unless metadata["general"]["identifier"].nil?
          metadata["general"]["identifier"] = [metadata["general"]["identifier"]] if metadata["general"]["identifier"].is_a? Hash
          unless metadata["general"]["identifier"].blank?
            fields["1.1.1"] = metadata["general"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["catalog"])}.compact.join(", ") unless metadata["general"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["catalog"])}.compact.blank?
            fields["1.1.2"] = metadata["general"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["entry"])}.compact.join(", ") unless metadata["general"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["entry"])}.compact.blank?
          end
        end
        fields["1.2"] = Metadata::Lom.getLangString(metadata["general"]["title"]) unless Metadata::Lom.getLangString(metadata["general"]["title"]).blank?
        fields["1.3"] = metadata_field_for_array(metadata["general"]["language"],"getCharacterString") unless metadata_field_for_array(metadata["general"]["language"],"getCharacterString").blank?
        fields["1.4"] = metadata_field_for_array(metadata["general"]["description"],"getLangString") unless metadata_field_for_array(metadata["general"]["description"],"getLangString").blank?
        fields["1.5"] = metadata_field_for_array(metadata["general"]["keyword"],"getLangString") unless metadata_field_for_array(metadata["general"]["keyword"],"getLangString").blank?
        fields["1.6"] = metadata_field_for_array(metadata["general"]["coverage"],"getLangString") unless metadata_field_for_array(metadata["general"]["coverage"],"getLangString").blank?
        fields["1.7"] = Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]) unless Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]).blank?
        fields["1.8"] = Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]) unless Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]).blank?
      end

      #Category 2
      unless metadata["lifecycle"].nil?
        fields["2.1"] = Metadata::Lom.getLangString(metadata["lifecycle"]["version"]) unless Metadata::Lom.getLangString(metadata["lifecycle"]["version"]).blank?
        fields["2.2"] = Metadata::Lom.getVocabularyItem(metadata["lifecycle"]["status"]) unless Metadata::Lom.getVocabularyItem(metadata["lifecycle"]["status"]).blank?
        
        unless metadata["lifecycle"]["contribute"].nil?
          metadata["lifecycle"]["contribute"] = [metadata["lifecycle"]["contribute"]] if metadata["lifecycle"]["contribute"].is_a? Hash
          unless metadata["lifecycle"]["contribute"].blank?
            fields["2.3.1"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.blank?
            fields["2.3.2"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
            fields["2.3.3"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.blank?
          end
        end
      end

      #Category 3
      unless metadata["metametadata"].nil?
        unless metadata["metametadata"]["identifier"].nil?
          metadata["metametadata"]["identifier"] = [metadata["metametadata"]["identifier"]] if metadata["metametadata"]["identifier"].is_a? Hash
          unless metadata["metametadata"]["identifier"].blank?
            fields["3.1.1"] = metadata["metametadata"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["catalog"])}.compact.join(", ") unless metadata["metametadata"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["catalog"])}.compact.blank?
            fields["3.1.2"] = metadata["metametadata"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["entry"])}.compact.join(", ") unless metadata["metametadata"]["identifier"].map{|i| Metadata::Lom.getCharacterString(i["entry"])}.compact.blank?
          end
        end
        unless metadata["metametadata"]["contribute"].nil?
          metadata["metametadata"]["contribute"] = [metadata["metametadata"]["contribute"]] if metadata["metametadata"]["contribute"].is_a? Hash
          unless metadata["metametadata"]["contribute"].blank?
            fields["3.2.1"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.blank?
            fields["3.2.2"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
            fields["3.2.3"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.blank?
          end
        end
        fields["3.3"] = metadata_field_for_array(metadata["metametadata"]["metadataschema"],"getCharacterString") unless metadata_field_for_array(metadata["metametadata"]["metadataschema"],"getCharacterString").blank?
        fields["3.4"] = Metadata::Lom.getCharacterString(metadata["metametadata"]["language"]) unless Metadata::Lom.getCharacterString(metadata["metametadata"]["language"]).blank?
      end

      #Category 4
      unless metadata["technical"].nil?
        fields["4.1"] = metadata_field_for_array(metadata["technical"]["format"],"getCharacterString") unless metadata_field_for_array(metadata["technical"]["format"],"getCharacterString").blank?
        fields["4.2"] = Metadata::Lom.getCharacterString(metadata["technical"]["size"]) unless Metadata::Lom.getCharacterString(metadata["technical"]["size"]).blank?
        fields["4.3"] = metadata_field_for_array(metadata["technical"]["location"],"getCharacterString") unless metadata_field_for_array(metadata["technical"]["location"],"getCharacterString").blank?
        unless metadata["technical"]["requirement"].nil?
          metadata["technical"]["requirement"] = [metadata["technical"]["requirement"]] if metadata["technical"]["requirement"].is_a? Hash
          unless metadata["technical"]["requirement"].blank?
            metadata["technical"]["requirement"] = metadata["technical"]["requirement"].map{|mf| mf["orcomposite"]}.flatten.compact
            unless metadata["technical"]["requirement"].blank?
              fields["4.4.1.1"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["type"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["type"])}.compact.blank?
              fields["4.4.1.2"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["name"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["name"])}.compact.blank?
              fields["4.4.1.3"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getCharacterString(c["minimumversion"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| Metadata::Lom.getCharacterString(c["minimumversion"])}.compact.empty?
              fields["4.4.1.4"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getCharacterString(c["maximumversion"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| Metadata::Lom.getCharacterString(c["maximumversion"])}.compact.empty?
            end
          end
        end
        fields["4.5"] = Metadata::Lom.getLangString(metadata["technical"]["installationremarks"]) unless Metadata::Lom.getLangString(metadata["technical"]["installationremarks"]).blank?
        fields["4.6"] = Metadata::Lom.getLangString(metadata["technical"]["otherplatformrequirements"]) unless Metadata::Lom.getLangString(metadata["technical"]["otherplatformrequirements"]).blank?
        fields["4.7"] = Metadata::Lom.getDuration(metadata["technical"]["duration"]) unless Metadata::Lom.getDuration(metadata["technical"]["duration"]).blank?
      end

      #Category 5
      unless metadata["educational"].nil?
        fields["5.1"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]).blank?
        fields["5.2"] = metadata_field_for_array(metadata["educational"]["learningresourcetype"],"getVocabularyItem") unless metadata_field_for_array(metadata["educational"]["learningresourcetype"],"getVocabularyItem").blank?
        fields["5.3"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]).blank?
        fields["5.4"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]).blank?
        fields["5.5"] = metadata_field_for_array(metadata["educational"]["intendedenduserrole"],"getVocabularyItem") unless metadata_field_for_array(metadata["educational"]["intendedenduserrole"],"getVocabularyItem").blank?
        fields["5.6"] = metadata_field_for_array(metadata["educational"]["context"],"getVocabularyItem") unless metadata_field_for_array(metadata["educational"]["context"],"getVocabularyItem").blank?
        fields["5.7"] = metadata_field_for_array(metadata["educational"]["typicalagerange"],"getLangString") unless metadata_field_for_array(metadata["educational"]["typicalagerange"],"getLangString").blank?
        fields["5.8"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]).blank?
        fields["5.9"] = Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]) unless Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]).blank?
        fields["5.10"] = metadata_field_for_array(metadata["educational"]["description"],"getLangString") unless metadata_field_for_array(metadata["educational"]["description"],"getLangString").blank?
        fields["5.11"] = metadata_field_for_array(metadata["educational"]["language"],"getCharacterString") unless metadata_field_for_array(metadata["educational"]["language"],"getCharacterString").blank?
      end

      #Category 6
      unless metadata["rights"].nil?
        fields["6.1"] = Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]) unless Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]).blank?
        fields["6.2"] = Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]) unless Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]).blank?
        fields["6.3"] = Metadata::Lom.getLangString(metadata["rights"]["description"]) unless Metadata::Lom.getLangString(metadata["rights"]["description"]).blank?
      end

      #Category 7
      unless metadata["relation"].nil?
        metadata["relation"] = [metadata["relation"]] if metadata["relation"].is_a? Hash
        fields["7.1"] = metadata["relation"].map{|c| Metadata::Lom.getVocabularyItem(c["kind"])}.compact.join(", ") unless metadata["relation"].map{|c| Metadata::Lom.getVocabularyItem(c["kind"])}.compact.blank?
        metadataResources = metadata["relation"].reject{|mr| mr["resource"].nil?}.map{|mr| mr["resource"]}
        unless metadataResources.empty?
          metadataIdentifiers = metadataResources.reject{|mr| mr["identifier"].nil?}.map{|mr| mr["identifier"]}.flatten.compact
          unless metadataIdentifiers.empty?
            fields["7.2.1.1"] = metadataIdentifiers.map{|c| Metadata::Lom.getCharacterString(c["catalog"])}.compact.join(", ") unless metadataIdentifiers.map{|c| Metadata::Lom.getCharacterString(c["catalog"])}.compact.blank?
            fields["7.2.1.2"] = metadataIdentifiers.map{|c| Metadata::Lom.getCharacterString(c["entry"])}.compact.join(", ") unless metadataIdentifiers.map{|c| Metadata::Lom.getCharacterString(c["entry"])}.compact.blank?
          end
          fields["7.2.2"] = metadataResources.map{|c| Metadata::Lom.getLangString(c["description"])}.flatten.compact.join(", ") unless metadataResources.map{|c| Metadata::Lom.getLangString(c["description"])}.flatten.compact.blank?
        end
      end

      #Category 8
      unless metadata["annotation"].nil?
        metadata["annotation"] = [metadata["annotation"]] if metadata["annotation"].is_a? Hash
        fields["8.1"] = metadata["annotation"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
        fields["8.2"] = metadata["annotation"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.blank?
        fields["8.3"] = metadata["annotation"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.blank?
      end

      #Category 9
      unless metadata["classification"].nil?
        metadata["classification"] = [metadata["classification"]] if metadata["classification"].is_a? Hash
        fields["9.1"] = metadata["classification"].map{|c| Metadata::Lom.getVocabularyItem(c["purpose"])}.compact.join(", ") unless metadata["classification"].map{|c| Metadata::Lom.getVocabularyItem(c["purpose"])}.compact.blank?
        taxonPaths = metadata["classification"].map{|c| c["taxonpath"]}.flatten.compact
        unless taxonPaths.blank?
          fields["9.2.1"] = taxonPaths.map{|c| Metadata::Lom.getLangString(c["source"])}.compact.join(", ") unless taxonPaths.map{|c| Metadata::Lom.getLangString(c["source"])}.compact.blank?
          metadataTaxons = taxonPaths.reject{|ct| ct["taxon"].nil?}.map{|ct| ct["taxon"]}.flatten.compact
          unless metadataTaxons.empty?
            fields["9.2.2.1"] = metadataTaxons.map{|c| Metadata::Lom.getCharacterString(c["id"])}.compact.join(", ") unless metadataTaxons.map{|c| Metadata::Lom.getCharacterString(c["id"])}.compact.blank?
            fields["9.2.2.2"] = metadataTaxons.map{|c| Metadata::Lom.getLangString(c["entry"])}.compact.join(", ") unless metadataTaxons.map{|c| Metadata::Lom.getLangString(c["entry"])}.compact.blank?
          end
        end
        fields["9.3"] = metadata["classification"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.join(", ") unless metadata["classification"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.blank?
        fields["9.4"] = metadata["classification"].map{|c| metadata_field_for_array(c["keyword"],"getLangString")}.flatten.compact.join(", ") unless metadata["classification"].map{|c| metadata_field_for_array(c["keyword"],"getLangString")}.flatten.compact.blank?
      end

      fields
    end

    def metadata_xml(metadataRecord)
      metadata_xml_from_json(metadata_json(metadataRecord))
    end

    def metadata_xml_from_json(metadataJSON={})
      metadata = metadataJSON
      metadata = {} unless metadata.is_a? Hash
      metadata_fields = metadata_fields_from_json(metadata)
      return Metadata.getEmptyXml if metadata_fields.blank?

      require 'builder'
      myxml = ::Builder::XmlMarkup.new(:indent => 2)
      myxml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
      
      lomHeaderOptions =  { 'xmlns' => "http://ltsc.ieee.org/xsd/LOM",
                            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xsi:schemaLocation' => "http://ltsc.ieee.org/xsd/LOM lom.xsd"
                          }

      #Language (LO language and metadata language)
      loLanguage = metadata_fields["1.3"].split(", ").first unless metadata_fields["1.3"].nil?
      loLanOpts = loLanguage.blank? ? {} : { :language=> loLanguage }
      metadataLanguage = metadata_fields["3.4"] || "en"

      myxml.tag!("lom",lomHeaderOptions) do
        
        unless metadata["general"].blank?
          myxml.general do
            unless metadata["general"]["identifier"].blank?
              metadata["general"]["identifier"] = [metadata["general"]["identifier"]] unless metadata["general"]["identifier"].is_a? Array
              metadata["general"]["identifier"].each do |identifier|
                myxml.identifier do
                  myxml.catalog(Metadata::Lom.getCharacterString(identifier["catalog"])) unless Metadata::Lom.getCharacterString(identifier["catalog"]).blank?
                  myxml.entry(Metadata::Lom.getCharacterString(identifier["entry"])) unless Metadata::Lom.getCharacterString(identifier["entry"]).blank?
                end
              end
            end

            unless Metadata::Lom.getLangString(metadata["general"]["title"]).blank?
              myxml.title do
                myxml.string(Metadata::Lom.getLangString(metadata["general"]["title"]), loLanOpts)
              end
            end

            unless metadata["general"]["language"].blank?
              metadata["general"]["language"] = [metadata["general"]["language"]] unless metadata["general"]["language"].is_a? Array
              metadata["general"]["language"].each do |language|
                myxml.language(Metadata::Lom.getCharacterString(language)) unless Metadata::Lom.getCharacterString(language).blank?
              end
            end

            unless metadata["general"]["description"].blank?
              metadata["general"]["description"] = [metadata["general"]["description"]] unless metadata["general"]["description"].is_a? Array
              metadata["general"]["description"].each do |description|
                unless Metadata::Lom.getLangString(description).blank?
                  myxml.description do
                    myxml.string(Metadata::Lom.getLangString(description), loLanOpts)
                  end
                end
              end
            end

            unless metadata["general"]["keyword"].blank?
              metadata["general"]["keyword"] = [metadata["general"]["keyword"]] unless metadata["general"]["keyword"].is_a? Array
              metadata["general"]["keyword"].each do |keyword|
                unless Metadata::Lom.getLangString(keyword).blank?
                  myxml.keyword do
                    myxml.string(Metadata::Lom.getLangString(keyword), loLanOpts)
                  end
                end
              end
            end

            unless metadata["general"]["coverage"].blank?
              metadata["general"]["coverage"] = [metadata["general"]["coverage"]] unless metadata["general"]["coverage"].is_a? Array
              metadata["general"]["coverage"].each do |coverage|
                unless Metadata::Lom.getLangString(coverage).blank?
                  myxml.coverage do
                    myxml.string(Metadata::Lom.getLangString(coverage), loLanOpts)
                  end
                end
              end
            end

            unless Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]).blank?
              myxml.structure do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]))
              end
            end

            unless Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]).blank?
              myxml.aggregationLevel do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]))
              end
            end

          end
        end

        unless metadata["lifecycle"].blank?
          myxml.lifeCycle do
            unless Metadata::Lom.getLangString(metadata["lifecycle"]["version"]).blank?
              myxml.version do
                myxml.string(Metadata::Lom.getLangString(metadata["lifecycle"]["version"]), :language=>metadataLanguage)
              end
            end
            unless Metadata::Lom.getVocabularyItem(metadata["lifecycle"]["status"]).blank?
              myxml.status do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["lifecycle"]["status"]))
              end
            end
            unless metadata["lifecycle"]["contribute"].blank?
              metadata["lifecycle"]["contribute"] = [metadata["lifecycle"]["contribute"]] unless metadata["lifecycle"]["contribute"].is_a? Array
              metadata["lifecycle"]["contribute"].each do |contributor|
                myxml.contribute do
                  unless Metadata::Lom.getVocabularyItem(contributor["role"]).blank?
                    myxml.role do
                      myxml.source(Metadata::Lom.schema)
                      myxml.value(Metadata::Lom.getVocabularyItem(contributor["role"]))
                    end
                  end
                  unless Metadata::Lom.getCharacterString(contributor["entity"]).blank?
                    myxml.entity(Metadata::Lom.getCharacterString(contributor["entity"]))
                  end
                  if contributor["date"] and !Metadata::Lom.getDatetime(contributor["date"]).blank?
                    myxml.date do
                      myxml.dateTime(Metadata::Lom.getDatetime(contributor["date"]))
                      unless Metadata::Lom.getLangString(contributor["date"]["description"]).blank?
                        myxml.description do
                          myxml.string(Metadata::Lom.getLangString(contributor["date"]["description"]), :language=> metadataLanguage)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        unless metadata["metametadata"].blank?
          myxml.metaMetadata do
            unless metadata["metametadata"]["identifier"].blank?
              metadata["metametadata"]["identifier"] = [metadata["metametadata"]["identifier"]] unless metadata["metametadata"]["identifier"].is_a? Array
              metadata["metametadata"]["identifier"].each do |identifier|
                myxml.identifier do
                  myxml.catalog(Metadata::Lom.getCharacterString(identifier["catalog"])) unless Metadata::Lom.getCharacterString(identifier["catalog"]).blank?
                  myxml.entry(Metadata::Lom.getCharacterString(identifier["entry"])) unless Metadata::Lom.getCharacterString(identifier["entry"]).blank?
                end
              end
            end
            unless metadata["metametadata"]["contribute"].blank?
              metadata["metametadata"]["contribute"] = [metadata["metametadata"]["contribute"]] unless metadata["metametadata"]["contribute"].is_a? Array
              metadata["metametadata"]["contribute"].each do |contributor|
                myxml.contribute do
                  unless Metadata::Lom.getVocabularyItem(contributor["role"]).blank?
                    myxml.role do
                      myxml.source(Metadata::Lom.schema)
                      myxml.value(Metadata::Lom.getVocabularyItem(contributor["role"]))
                    end
                  end
                  unless Metadata::Lom.getCharacterString(contributor["entity"]).blank?
                    myxml.entity(Metadata::Lom.getCharacterString(contributor["entity"]))
                  end
                  if contributor["date"] and !Metadata::Lom.getDatetime(contributor["date"]).blank?
                    myxml.date do
                      myxml.dateTime(Metadata::Lom.getDatetime(contributor["date"]))
                      unless Metadata::Lom.getLangString(contributor["date"]["description"]).blank?
                        myxml.description do
                          myxml.string(Metadata::Lom.getLangString(contributor["date"]["description"]), :language=> metadataLanguage)
                        end
                      end
                    end
                  end
                end
              end
            end
            myxml.metadataSchema(Metadata::Lom.schema)
            myxml.language(metadataLanguage)
          end
        end

        unless metadata["technical"].blank?
          myxml.technical do
            unless metadata["technical"]["format"].blank?
              metadata["technical"]["format"] = [metadata["technical"]["format"]] unless metadata["technical"]["format"].is_a? Array
              metadata["technical"]["format"].each do |format|
                myxml.format(Metadata::Lom.getCharacterString(format)) unless Metadata::Lom.getCharacterString(format).blank?
              end
            end
            unless Metadata::Lom.getCharacterString(metadata["technical"]["size"]).blank?
              myxml.size(Metadata::Lom.getCharacterString(metadata["technical"]["size"]))
            end
            unless metadata["technical"]["location"].blank?
              metadata["technical"]["location"] = [metadata["technical"]["location"]] unless metadata["technical"]["location"].is_a? Array
              metadata["technical"]["location"].each do |location|
                myxml.location(Metadata::Lom.getCharacterString(location)) unless Metadata::Lom.getCharacterString(location).blank?
              end
            end
            unless metadata["technical"]["requirement"].blank?
              myxml.requirement do
                metadata["technical"]["requirement"] = [metadata["technical"]["requirement"]] unless metadata["technical"]["requirement"].is_a? Array
                metadata["technical"]["requirement"].map{|orC| orC["orcomposite"]}.flatten.compact.each do |orComposite|
                  unless orComposite.blank?
                    myxml.orComposite do
                      unless Metadata::Lom.getVocabularyItem(orComposite["type"]).blank?
                        myxml.type do
                          myxml.source(Metadata::Lom.schema)
                          myxml.value(Metadata::Lom.getVocabularyItem(orComposite["type"]))
                        end
                      end
                      unless Metadata::Lom.getVocabularyItem(orComposite["name"]).blank?
                        myxml.name do
                          myxml.source(Metadata::Lom.schema)
                          myxml.value(Metadata::Lom.getVocabularyItem(orComposite["name"]))
                        end
                      end
                      unless Metadata::Lom.getCharacterString(orComposite["minimumversion"]).blank?
                        myxml.minimumVersion(Metadata::Lom.getCharacterString(orComposite["minimumversion"]))
                      end
                      unless Metadata::Lom.getCharacterString(orComposite["maximumversion"]).blank?
                        myxml.maximumVersion(Metadata::Lom.getCharacterString(orComposite["maximumversion"]))
                      end
                    end
                  end
                end
              end
            end
            unless Metadata::Lom.getLangString(metadata["technical"]["installationremarks"]).blank?
              myxml.installationRemarks do
                myxml.string(Metadata::Lom.getLangString(metadata["technical"]["installationremarks"]), :language=> metadataLanguage)
              end
            end
            unless Metadata::Lom.getLangString(metadata["technical"]["otherplatformrequirements"]).blank?
              myxml.otherPlatformRequirements do
                myxml.string(Metadata::Lom.getLangString(metadata["technical"]["otherplatformrequirements"]), :language=> metadataLanguage)
              end
            end
            unless Metadata::Lom.getDuration(metadata["technical"]["duration"]).blank?
              myxml.duration do
                myxml.duration(Metadata::Lom.getDuration(metadata["technical"]["duration"]))
                unless Metadata::Lom.getLangString(metadata["technical"]["duration"]["description"]).blank?
                  myxml.description do
                    myxml.string(Metadata::Lom.getLangString(metadata["technical"]["duration"]["description"]), :language=> metadataLanguage)
                  end
                end
              end
            end
          end
        end

        unless metadata["educational"].blank?
          myxml.educational do
            unless Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]).blank?
              myxml.interactivityType do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]))
              end
            end
            unless metadata["educational"]["learningresourcetype"].blank?
              metadata["educational"]["learningresourcetype"] = [metadata["educational"]["learningresourcetype"]] unless metadata["educational"]["learningresourcetype"].is_a? Array
              metadata["educational"]["learningresourcetype"].compact.each do |lrt|
                unless Metadata::Lom.getVocabularyItem(lrt).blank?
                  myxml.learningResourceType do
                    myxml.source(Metadata::Lom.schema)
                    myxml.value(Metadata::Lom.getVocabularyItem(lrt))
                  end
                end
              end
            end
            unless Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]).blank?
              myxml.interactivityLevel do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]))
              end
            end
            unless Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]).blank?
              myxml.semanticDensity do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]))
              end
            end
            unless metadata["educational"]["intendedenduserrole"].blank?
              metadata["educational"]["intendedenduserrole"] = [metadata["educational"]["intendedenduserrole"]] unless metadata["educational"]["intendedenduserrole"].is_a? Array
              metadata["educational"]["intendedenduserrole"].compact.each do |ieur|
                unless Metadata::Lom.getVocabularyItem(ieur).blank?
                  myxml.intendedEndUserRole do
                    myxml.source(Metadata::Lom.schema)
                    myxml.value(Metadata::Lom.getVocabularyItem(ieur))
                  end
                end
              end
            end
            unless metadata["educational"]["context"].blank?
              metadata["educational"]["context"] = [metadata["educational"]["context"]] unless metadata["educational"]["context"].is_a? Array
              metadata["educational"]["context"].compact.each do |context|
                unless Metadata::Lom.getVocabularyItem(context).blank?
                  myxml.context do
                    myxml.source(Metadata::Lom.schema)
                    myxml.value(Metadata::Lom.getVocabularyItem(context))
                  end
                end
              end
            end
            unless metadata["educational"]["typicalagerange"].blank?
              metadata["educational"]["typicalagerange"] = [metadata["educational"]["typicalagerange"]] unless metadata["educational"]["typicalagerange"].is_a? Array
              metadata["educational"]["typicalagerange"].compact.each do |tagr|
                unless Metadata::Lom.getLangString(tagr).blank?
                  myxml.typicalAgeRange do
                    myxml.string(Metadata::Lom.getLangString(tagr), :language=> metadataLanguage)
                  end
                end
              end
            end
            unless Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]).blank?
              myxml.difficulty do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]))
              end
            end
            unless Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]).blank?
              myxml.typicalLearningTime do
                myxml.duration(Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]))
                unless Metadata::Lom.getLangString(metadata["educational"]["typicallearningtime"]["description"]).blank?
                  myxml.description do
                    myxml.string(Metadata::Lom.getLangString(metadata["educational"]["typicallearningtime"]["description"]), :language=> metadataLanguage)
                  end
                end
              end
            end
            unless metadata["educational"]["description"].blank?
              metadata["educational"]["description"] = [metadata["educational"]["description"]] unless metadata["educational"]["description"].is_a? Array
              metadata["educational"]["description"].compact.each do |description|
                unless Metadata::Lom.getLangString(description).blank?
                  myxml.description do
                    myxml.string(Metadata::Lom.getLangString(description), loLanOpts)
                  end
                end
              end
            end
            unless metadata["educational"]["language"].blank?
              metadata["educational"]["language"] = [metadata["educational"]["language"]] unless metadata["educational"]["language"].is_a? Array
              metadata["educational"]["language"].compact.each do |language|
                unless Metadata::Lom.getCharacterString(language).blank?
                  myxml.language(Metadata::Lom.getCharacterString(language))
                end
              end
            end
          end
        end

        unless metadata["rights"].blank?
          myxml.rights do
            unless Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]).blank?
              myxml.cost do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]))
              end
            end

            unless Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]).blank?
              myxml.copyrightAndOtherRestrictions do
                myxml.source(Metadata::Lom.schema)
                myxml.value(Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]))
              end
            end

            unless Metadata::Lom.getLangString(metadata["rights"]["description"]).blank?
              myxml.description do
                myxml.string(Metadata::Lom.getLangString(metadata["rights"]["description"]), :language=> metadataLanguage)
              end
            end
          end
        end

        unless metadata["relation"].blank?
          metadata["relation"] = [metadata["relation"]] unless metadata["relation"].is_a? Array
          metadata["relation"].each do |relation|
            myxml.relation do
              unless Metadata::Lom.getVocabularyItem(relation["kind"]).blank?
                myxml.kind do
                  myxml.source(Metadata::Lom.schema)
                  myxml.value(Metadata::Lom.getVocabularyItem(relation["kind"]))
                end
              end
              unless relation["resource"].blank?
                myxml.resource do
                  unless relation["resource"]["identifier"].blank?
                    myxml.identifier do
                      myxml.catalog(Metadata::Lom.getCharacterString(relation["resource"]["identifier"]["catalog"])) unless Metadata::Lom.getCharacterString(relation["resource"]["identifier"]["catalog"]).blank?
                      myxml.entry(Metadata::Lom.getCharacterString(relation["resource"]["identifier"]["entry"])) unless Metadata::Lom.getCharacterString(relation["resource"]["identifier"]["entry"]).blank?
                    end
                  end
                  relation["resource"]["description"] = [relation["resource"]["description"]] if relation["resource"]["description"].is_a? Hash
                  unless relation["resource"]["description"].blank?
                    relation["resource"]["description"].each do |description|
                      unless Metadata::Lom.getLangString(description).blank?
                        myxml.description do
                          relatedResourceDescLanguage = description["string"]["@attributes"]["language"] if description["string"]["@attributes"].is_a? Hash and description["string"]["@attributes"]["language"].is_a? String
                          relatedResourceDescLanguage = metadataLanguage if relatedResourceDescLanguage.nil?
                          myxml.string(Metadata::Lom.getLangString(description), :language => relatedResourceDescLanguage)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        unless metadata["annotation"].blank?
          metadata["annotation"] = [metadata["annotation"]] unless metadata["annotation"].is_a? Array
          metadata["annotation"].each do |annotation|
            myxml.annotation do
              myxml.entity(Metadata::Lom.getCharacterString(annotation["entity"])) unless Metadata::Lom.getCharacterString(annotation["entity"]).blank?
              unless Metadata::Lom.getDatetime(annotation["date"]).blank?
                myxml.date do
                  myxml.dateTime(Metadata::Lom.getDatetime(annotation["date"]))
                  unless Metadata::Lom.getLangString(annotation["date"]["description"]).blank?
                    myxml.description do
                      myxml.string(Metadata::Lom.getLangString(annotation["date"]["description"]), :language=> metadataLanguage)
                    end
                  end
                end
              end
              unless Metadata::Lom.getLangString(annotation["description"]).blank?
                myxml.description do
                  annotationLanguage = annotation["description"]["@attributes"]["language"] if annotation["description"]["@attributes"].is_a? Hash and annotation["description"]["@attributes"]["language"].is_a? String
                  annotationLanguage = metadataLanguage if annotationLanguage.nil?
                  myxml.string(Metadata::Lom.getLangString(annotation["description"]), :language=> annotationLanguage)
                end
              end
            end
          end
        end

        unless metadata["classification"].blank?
          metadata["classification"] = [metadata["classification"]] unless metadata["classification"].is_a? Array
          metadata["classification"].each do |classification|
            myxml.classification do
              unless Metadata::Lom.getVocabularyItem(classification["purpose"]).blank?
                myxml.purpose do
                  myxml.source(Metadata::Lom.schema)
                  myxml.value(Metadata::Lom.getVocabularyItem(classification["purpose"]))
                end
              end
              unless classification["taxonpath"].blank?
                classification["taxonpath"] = [classification["taxonpath"]] unless classification["taxonpath"].is_a? Array
                classification["taxonpath"].each do |taxonPath|
                  myxml.taxonPath do
                    unless Metadata::Lom.getLangString(taxonPath["source"]).blank?
                      myxml.source do
                        myxml.string(Metadata::Lom.getLangString(taxonPath["source"]))
                      end
                    end
                    unless taxonPath["taxon"].blank?
                      taxonPath["taxon"] = [taxonPath["taxon"]] unless taxonPath["taxon"].is_a? Array
                      taxonPath["taxon"].each do |taxon|
                        myxml.taxon do
                          myxml.id(Metadata::Lom.getCharacterString(taxon["id"])) unless Metadata::Lom.getCharacterString(taxon["id"]).blank?
                          myxml.entry do
                            myxml.string(Metadata::Lom.getLangString(taxon["entry"])) unless Metadata::Lom.getLangString(taxon["entry"]).blank?
                          end
                        end
                      end
                    end
                  end
                end
              end
              unless Metadata::Lom.getLangString(classification["description"]).blank?
                myxml.description do
                  myxml.string(Metadata::Lom.getLangString(classification["description"]), :language=> metadataLanguage)
                end
              end
              unless classification["keyword"].blank?
                classification["keyword"] = [classification["keyword"]] unless classification["keyword"].is_a? Array
                classification["keyword"].each do |keyword|
                  unless Metadata::Lom.getLangString(keyword).blank?
                    myxml.keyword do
                      myxml.string(Metadata::Lom.getLangString(keyword), :language=> metadataLanguage)
                    end
                  end
                end
              end
            end
          end
        end

      end

      return myxml.target!
    end


    # LOM datatype Methods
    def getCharacterString(characterString)
      characterString["value"] if (!characterString.nil? and characterString["value"].is_a? String)
    end

    def getLangString(langString)
      return langString["string"]["value"] if (!langString.nil? and langString["string"].is_a? Hash and !langString["string"].blank? and langString["string"]["value"].is_a? String)
      return langString["string"].map{|ls| ls["value"]}.compact.join(", ") if (!langString.nil? and langString["string"].is_a? Array and !langString["string"].map{|ls| ls["value"]}.compact.blank?)
    end

    def getVocabularyItem(vocabulary)
      return vocabulary["value"]["value"] if (!vocabulary.nil? and vocabulary.is_a? Hash and vocabulary["value"].is_a? Hash and vocabulary["value"]["value"].is_a? String)
      return vocabulary.select{|v| v["value"].is_a? Hash and v["value"]["value"].is_a? String}.map{|v| v["value"]["value"]}.join(", ") if (!vocabulary.nil? and vocabulary.is_a? Array and !vocabulary.empty? and !vocabulary.select{|v| v["value"].is_a? Hash and v["value"]["value"].is_a? String}.map{|v| v["value"]["value"]}.compact.blank? )
    end

    def getVCARD(vcard)
      if vcard.is_a? Hash and vcard["value"].is_a? String
        vcard = vcard["value"].gsub("&#xD;","\n")
        decoded_vcard = Vpim::Vcard.decode(vcard) rescue nil
        unless decoded_vcard.nil?
          decoded_vcard[0].name.fullname rescue nil
        end
      end
    end

    def getDatetime(datetime)
      return datetime["datetime"]["value"] if (!datetime.nil? and datetime["datetime"].is_a? Hash and datetime["datetime"]["value"].is_a? String)
      return datetime.select{|d| d["datetime"].is_a? Hash and d["datetime"]["value"].is_a? String}.map{|d| d["datetime"]["value"]}.join(", ") if (!datetime.nil? and datetime.is_a? Array and !datetime.empty? and !datetime.select{|d| d["datetime"].is_a? Hash and d["datetime"]["value"].is_a? String}.map{|d| d["datetime"]["value"]}.compact.blank? )
    end

    def getDuration(duration)
      duration["duration"]["value"] if (!duration.nil? and duration["duration"].is_a? Hash and duration["duration"]["value"].is_a? String)
    end

    def categories
      ["general","lifecycle","metametadata","technical","educational","rights","relation","annotation","classification"]
    end

    #Helpers
    def metadata_field_for_array(field,dataTypeMethod="getCharacterString")
      unless field.nil?
        field = [field] if field.is_a? Hash
        unless field.blank?
          field.map{|e| send(dataTypeMethod,e)}.compact.join(", ") unless field.map{|e| send(dataTypeMethod,e)}.compact.blank?
        end
      end
    end

  end

end