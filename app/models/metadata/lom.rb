class Metadata::Lom < Metadata

  class << self

    def compliant?(xmlDoc)
      lom = xmlDoc.at_xpath('//lom') rescue nil
      return false unless lom.is_a? Nokogiri::XML::Element
      return false unless lom.attributes.is_a? Hash
      return false unless lom.attributes["xmlns"].is_a? Nokogiri::XML::Attr
      return false unless lom.attributes["xmlns"].value.include? "LOM"
      true
    end

    def getContent(xmlDoc)
      xmlDoc.at_xpath('//lom')
    end

    def schema
      "LOMv1.0"
    end

    def metadata_json(metadataRecord)
      metadata = JSON.parse(metadataRecord.lom_content)["lom"] rescue {}
      metadata = {} if metadata.blank?
      return metadata
    end

    def metadata_fields(metadataRecord)
      fields = {}

      metadata = metadata_json(metadataRecord)

      #Category 1
      unless metadata["general"].nil?
        unless metadata["general"]["identifier"].nil?
          fields["1.1.1"] = metadata["general"]["identifier"]["catalog"] unless metadata["general"]["identifier"]["catalog"].blank?
          fields["1.1.2"] = metadata["general"]["identifier"]["entry"] unless metadata["general"]["identifier"]["entry"].blank?
        end
        fields["1.2"] = Metadata::Lom.getLangString(metadata["general"]["title"]) unless Metadata::Lom.getLangString(metadata["general"]["title"]).blank?
        fields["1.3"] = metadata["general"]["language"] unless metadata["general"]["language"].blank?
        fields["1.4"] = Metadata::Lom.getLangString(metadata["general"]["description"]) unless Metadata::Lom.getLangString(metadata["general"]["description"]).blank?
        fields["1.5"] = metadata["general"]["keyword"].map{|k| Metadata::Lom.getLangString(k) }.compact.join(", ") unless (!metadata["general"]["keyword"].is_a? Array or metadata["general"]["keyword"].map{|k| Metadata::Lom.getLangString(k) }.compact.empty?)
        fields["1.6"] = Metadata::Lom.getLangString(metadata["general"]["coverage"]) unless Metadata::Lom.getLangString(metadata["general"]["coverage"]).blank?
        fields["1.7"] = Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]) unless Metadata::Lom.getVocabularyItem(metadata["general"]["structure"]).blank?
        fields["1.8"] = Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]) unless Metadata::Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]).blank?
      end

      #Category 2
      unless metadata["lifecycle"].nil?
        fields["2.1"] = Metadata::Lom.getLangString(metadata["lifecycle"]["version"]) unless metadata["lifecycle"]["version"].blank?
        fields["2.2"] = Metadata::Lom.getVocabularyItem(metadata["lifecycle"]["status"]) unless metadata["lifecycle"]["status"].blank?
        if metadata["lifecycle"]["contribute"].is_a? Hash
          metadata["lifecycle"]["contribute"] = [metadata["lifecycle"]["contribute"]]
        end
        if metadata["lifecycle"]["contribute"].is_a? Array
          fields["2.3.1"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| c["role"]}.compact.blank?
          fields["2.3.2"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
          fields["2.3.3"] = metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.join(", ") unless metadata["lifecycle"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.blank?
        end
      end

      #Category 3
      unless metadata["metametadata"].nil?
        unless metadata["metametadata"]["identifier"].nil?
          fields["3.1.1"] = metadata["metametadata"]["identifier"]["catalog"] unless metadata["metametadata"]["identifier"]["catalog"].blank?
          fields["3.1.2"] = metadata["metametadata"]["identifier"]["entry"] unless metadata["metametadata"]["identifier"]["entry"].blank?
        end
        if metadata["metametadata"]["contribute"].is_a? Hash
          metadata["metametadata"]["contribute"] = [metadata["metametadata"]["contribute"]]
        end
        if metadata["metametadata"]["contribute"].is_a? Array
          fields["3.2.1"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVocabularyItem(c["role"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| c["role"]}.compact.blank?
          fields["3.2.2"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
          fields["3.2.3"] = metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.join(", ") unless metadata["metametadata"]["contribute"].map{|c| Metadata::Lom.getDatetime(c["date"])}.compact.blank?
        end
        fields["3.3"] = metadata["metametadata"]["metadataschema"] unless metadata["metametadata"]["metadataschema"].blank?
        fields["3.4"] = metadata["metametadata"]["language"] unless metadata["metametadata"]["language"].blank?
      end

      #Category 4
      unless metadata["technical"].nil?
        fields["4.1"] = metadata["technical"]["format"] unless metadata["technical"]["format"].blank?
        fields["4.2"] = metadata["technical"]["size"] unless metadata["technical"]["size"].blank?
        fields["4.3"] = metadata["technical"]["location"] unless metadata["technical"]["location"].blank?
        unless metadata["technical"]["requirement"].nil?
          if metadata["technical"]["requirement"].is_a? Hash
            metadata["technical"]["requirement"] = [metadata["technical"]["requirement"]]
          end
          if metadata["technical"]["requirement"].is_a? Array
            metadata["technical"]["requirement"] = metadata["technical"]["requirement"].reject{|mf| mf["orcomposite"].blank?}.map{|mf| mf["orcomposite"]}
            if metadata["technical"]["requirement"].length > 0
              fields["4.4.1.1"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["type"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| c["type"]}.compact.blank?
              fields["4.4.1.2"] = metadata["technical"]["requirement"].map{|c| Metadata::Lom.getVocabularyItem(c["name"])}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| c["name"]}.compact.blank?
              fields["4.4.1.3"] = metadata["technical"]["requirement"].map{|c| c["minimumversion"]}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| c["minimumversion"]}.compact.blank?
              fields["4.4.1.4"] = metadata["technical"]["requirement"].map{|c| c["maximumversion"]}.compact.join(", ") unless metadata["technical"]["requirement"].map{|c| c["maximumversion"]}.compact.blank?
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
        fields["5.2"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["learningresourcetype"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["learningresourcetype"]).blank?
        fields["5.3"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]).blank?
        fields["5.4"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]).blank?
        fields["5.5"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["intendedenduserrole"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["intendedenduserrole"]).blank?
        fields["5.6"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["context"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["context"]).blank?
        fields["5.7"] = Metadata::Lom.getLangString(metadata["educational"]["typicalagerange"]) unless Metadata::Lom.getLangString(metadata["educational"]["typicalagerange"]).blank?
        fields["5.8"] = Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]) unless Metadata::Lom.getVocabularyItem(metadata["educational"]["difficulty"]).blank?
        fields["5.9"] = Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]) unless Metadata::Lom.getDuration(metadata["educational"]["typicallearningtime"]).blank?
        fields["5.10"] = Metadata::Lom.getLangString(metadata["educational"]["description"]) unless Metadata::Lom.getLangString(metadata["educational"]["description"]).blank?
        fields["5.11"] = metadata["educational"]["language"] unless metadata["educational"]["language"].blank?
      end

      #Category 6
      unless metadata["rights"].nil?
        fields["6.1"] = Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]) unless Metadata::Lom.getVocabularyItem(metadata["rights"]["cost"]).blank?
        fields["6.2"] = Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]) unless Metadata::Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]).blank?
        fields["6.3"] = Metadata::Lom.getLangString(metadata["rights"]["description"]) unless Metadata::Lom.getLangString(metadata["rights"]["description"]).blank?
      end

      #Category 7
      unless metadata["relation"].nil?
        if metadata["relation"].is_a? Hash
          metadata["relation"] = [metadata["relation"]]
        end
        fields["7.1"] = metadata["relation"].map{|c| Metadata::Lom.getVocabularyItem(c["kind"])}.compact.join(", ") unless metadata["relation"].map{|c| c["kind"]}.compact.blank?
        metadataResources = metadata["relation"].reject{|mr| mr["resource"].nil?}.map{|mr| mr["resource"]}
        unless metadataResources.empty?
          metadataIdentifiers = metadataResources.reject{|mr| mr["identifier"].nil?}.map{|mr| mr["identifier"]}
          unless metadataIdentifiers.empty?
            fields["7.2.1.1"] = metadataIdentifiers.map{|c| c["catalog"]}.compact.join(", ") unless metadataIdentifiers.map{|c| c["catalog"]}.compact.blank?
            fields["7.2.1.2"] = metadataIdentifiers.map{|c| c["entry"]}.compact.join(", ") unless metadataIdentifiers.map{|c| c["entry"]}.compact.blank?
          end
          fields["7.2.2"] = metadataResources.map{|c| Metadata::Lom.getLangString(c["description"])}.compact.join(", ") unless metadataResources.map{|c| Metadata::Lom.getLangString(c["description"])}.compact.blank?
        end
      end

      #Category 8
      unless metadata["annotation"].nil?
        if metadata["annotation"].is_a? Hash
          metadata["annotation"] = [metadata["annotation"]]
        end
        fields["8.1"] = metadata["annotation"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getVCARD(c["entity"])}.compact.blank?
        fields["8.2"] = metadata["annotation"].map{|c| Metadata::Lom.getDateTime(c["date"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getDateTime(c["date"])}.compact.blank?
        fields["8.3"] = metadata["annotation"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.join(", ") unless metadata["annotation"].map{|c| Metadata::Lom.getLangString(c["description"])}.compact.blank?
      end

      #Category 9
      unless metadata["classification"].nil?
        fields["9.1"] = Metadata::Lom.getVocabularyItem(metadata["classification"]["purpose"]) unless Metadata::Lom.getVocabularyItem(metadata["classification"]["purpose"]).blank?
        unless metadata["classification"]["taxonpath"].nil?
          if metadata["classification"]["taxonpath"].is_a? Hash
            metadata["classification"]["taxonpath"] = [metadata["classification"]["taxonpath"]]
          end
          fields["9.2.1"] = metadata["classification"]["taxonpath"].map{|c| Metadata::Lom.getLangString(c["source"])}.compact.join(", ") unless metadata["classification"]["taxonpath"].map{|c| Metadata::Lom.getLangString(c["source"])}.compact.blank?
          metadataTaxons = metadata["classification"]["taxonpath"].reject{|ct| ct["taxon"].nil?}.map{|ct| ct["taxon"]}
          unless metadataTaxons.empty?
            fields["9.2.2.1"] = metadataTaxons.map{|c| c["id"]}.compact.join(", ") unless metadataTaxons.map{|c| c["id"]}.compact.blank?
            fields["9.2.2.2"] = metadataTaxons.map{|c| Metadata::Lom.getLangString(c["entry"])}.compact.join(", ") unless metadataTaxons.map{|c| Metadata::Lom.getLangString(c["entry"])}.compact.blank?
          end
        end
        fields["9.3"] = Metadata::Lom.getLangString(metadata["classification"]["description"]) unless Metadata::Lom.getLangString(metadata["classification"]["description"]).blank?
        fields["9.4"] = metadata["classification"]["keyword"].map{|k| Metadata::Lom.getLangString(k)}.compact.join(", ") unless (!metadata["classification"]["keyword"].is_a? Array or metadata["classification"]["keyword"].map{|k| Metadata::Lom.getLangString(k)}.compact.empty?)
      end

      fields
    end

    def metadata_xml(metadataRecord)
      metadata = metadata_json(metadataRecord)
      metadata_fields = metadata_fields(metadataRecord)

      return Metadata.getEmptyXml if metadata_fields.blank?

      require 'builder'
      myxml = ::Builder::XmlMarkup.new(:indent => 2)
      myxml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
      
      lomHeaderOptions =  { 'xmlns' => "http://ltsc.ieee.org/xsd/LOM",
                            'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xsi:schemaLocation' => "http://ltsc.ieee.org/xsd/LOM lom.xsd"
                          }

      #Language (LO language and metadata language)
      loLanguage = metadata_fields["1.3"]
      if loLanguage.nil?
        loLanOpts = {}
      else
        loLanOpts = { :language=> loLanguage }
      end
      metadataLanguage = metadata_fields["3.4"] || "en"

      myxml.tag!("lom",lomHeaderOptions) do
        
        unless metadata["general"].blank?
          myxml.general do
            unless metadata_fields["1.1.1"].blank? and metadata_fields["1.1.2"].blank?
              myxml.identifier do
                myxml.catalog(metadata_fields["1.1.1"]) unless metadata_fields["1.1.1"].blank?
                myxml.entry(metadata_fields["1.1.2"]) unless metadata_fields["1.1.2"].blank?
              end
            end

            unless metadata_fields["1.2"].blank?
              myxml.title do
                myxml.string(metadata_fields["1.2"], loLanOpts)
              end
            end

            unless metadata_fields["1.3"].blank?
              myxml.language(metadata_fields["1.3"])
            end

            unless metadata_fields["1.4"].blank?
              myxml.description do
                myxml.string(metadata_fields["1.4"], loLanOpts)
              end
            end

            unless metadata_fields["1.5"].blank?
              metadata_fields["1.5"].split(", ").each do |tag|
                myxml.keyword do
                  myxml.string(tag.to_s, loLanOpts)
                end
              end
            end

            unless metadata_fields["1.6"].blank?
              myxml.coverage do
                myxml.string(metadata_fields["1.6"], loLanOpts)
              end
            end

            unless metadata_fields["1.7"].blank?
              myxml.structure do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["1.7"])
              end
            end

            unless metadata_fields["1.8"].blank?
              myxml.aggregationLevel do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["1.8"])
              end
            end
          end
        end

        unless metadata["lifecycle"].blank?
          myxml.lifeCycle do
            unless metadata_fields["2.1"].blank?
              myxml.version do
                myxml.string(metadata_fields["2.1"], :language=>metadataLanguage)
              end
            end
            unless metadata_fields["2.2"].blank?
              myxml.status do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["2.2"])
              end
            end
            unless metadata["lifecycle"]["contribute"].blank?
              metadata["lifecycle"]["contribute"] = [metadata["lifecycle"]["contribute"]] unless metadata["lifecycle"]["contribute"].is_a? Array
              metadata["lifecycle"]["contribute"].each do |contributor|
                myxml.contribute do
                  if contributor["role"] and contributor["role"]["value"].is_a? String
                    myxml.role do
                      myxml.source(Metadata::Lom.schema)
                      myxml.value(contributor["role"]["value"])
                    end
                  end
                  if contributor["entity"].is_a? String
                    myxml.entity(contributor["entity"])
                  end
                  if contributor["date"] and contributor["date"]["datetime"].is_a? String
                    myxml.date do
                      myxml.dateTime(contributor["date"]["datetime"])
                      unless contributor["date"]["description"].blank? or !contributor["date"]["description"]["string"].is_a? String
                        myxml.description do
                          myxml.string(contributor["date"]["description"]["string"], :language=> metadataLanguage)
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
            unless metadata_fields["3.1.1"].blank? and metadata_fields["3.1.2"].blank?
              myxml.identifier do
                unless metadata_fields["3.1.1"].blank?
                  myxml.catalog(metadata_fields["3.1.1"])
                end
                unless metadata_fields["3.1.2"].blank?
                  myxml.entry(metadata_fields["3.1.2"])
                end
              end
            end
            unless metadata["metametadata"]["contribute"].blank?
              metadata["metametadata"]["contribute"] = [metadata["metametadata"]["contribute"]] unless metadata["metametadata"]["contribute"].is_a? Array
              metadata["metametadata"]["contribute"].each do |contributor|
                myxml.contribute do
                  if contributor["role"] and contributor["role"]["value"].is_a? String
                    myxml.role do
                      myxml.source(Metadata::Lom.schema)
                      myxml.value(contributor["role"]["value"])
                    end
                  end
                  if contributor["entity"].is_a? String
                    myxml.entity(contributor["entity"])
                  end
                  if contributor["date"] and contributor["date"]["datetime"].is_a? String
                    myxml.date do
                      myxml.dateTime(contributor["date"]["datetime"])
                      unless contributor["date"]["description"].blank? or !contributor["date"]["description"]["string"].is_a? String
                        myxml.description do
                          myxml.string(contributor["date"]["description"]["string"], :language=> metadataLanguage)
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
            unless metadata_fields["4.1"].blank?
              myxml.format(metadata_fields["4.1"])
            end
            unless metadata_fields["4.2"].blank?
              myxml.size(metadata_fields["4.2"])
            end
            unless metadata_fields["4.3"].blank?
              myxml.location(metadata_fields["4.3"])
            end
            unless metadata["technical"]["requirement"].blank?
              myxml.requirement do
                metadata["technical"]["requirement"] = [metadata["technical"]["requirement"]] unless metadata["technical"]["requirement"].is_a? Array
                metadata["technical"]["requirement"].map{|orC| orC["orcomposite"]}.compact.each do |orComposite|
                  unless orComposite.blank?
                    myxml.orComposite do
                      unless orComposite["type"].blank? or !orComposite["type"]["value"].is_a? String
                        myxml.type do
                          myxml.source(Metadata::Lom.schema)
                          myxml.value(orComposite["type"]["value"])
                        end
                      end
                      unless orComposite["name"].blank? or !orComposite["name"]["value"].is_a? String
                        myxml.name do
                          myxml.source(Metadata::Lom.schema)
                          myxml.value(orComposite["name"]["value"])
                        end
                      end
                      unless !orComposite["minimumversion"].is_a? String
                        myxml.minimumVersion(orComposite["minimumversion"])
                      end
                      unless !orComposite["maximumversion"].is_a? String
                        myxml.maximumVersion(orComposite["maximumversion"])
                      end
                    end
                  end
                end
              end
            end
            unless metadata_fields["4.5"].blank?
              myxml.installationRemarks do
                myxml.string(metadata_fields["4.5"], :language=> metadataLanguage)
              end
            end
            unless metadata_fields["4.6"].blank?
              myxml.otherPlatformRequirements do
                myxml.string(metadata_fields["4.6"], :language=> metadataLanguage)
              end
            end
            unless metadata_fields["4.7"].blank?
              myxml.duration do
                myxml.duration(metadata_fields["4.7"])
                unless metadata["technical"]["duration"]["description"].blank?
                  myxml.description(metadata["technical"]["duration"]["description"])
                end
              end
            end
          end
        end

        unless metadata["educational"].blank?
          myxml.educational do
            unless metadata_fields["5.1"].blank?
              myxml.interactivityType do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.1"])
              end
            end
            unless metadata_fields["5.2"].blank?
              metadata["educational"]["learningresourcetype"] = [metadata["educational"]["learningresourcetype"]] unless metadata["educational"]["learningresourcetype"].is_a? Array
              metadata["educational"]["learningresourcetype"].compact.each do |lrt|
                if lrt["value"].is_a? String
                  myxml.learningResourceType do
                    myxml.source(Metadata::Lom.schema)
                    myxml.value(lrt["value"])
                  end
                end
              end
            end
            unless metadata_fields["5.3"].blank?
              myxml.interactivityLevel do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.3"])
              end
            end
            unless metadata_fields["5.4"].blank?
              myxml.semanticDensity do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.4"])
              end
            end
            unless metadata_fields["5.5"].blank?
              myxml.intendedEndUserRole do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.5"])
              end
            end
            unless metadata_fields["5.6"].blank?
              myxml.context do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.6"])
              end
            end
            unless metadata_fields["5.7"].blank?
              myxml.typicalAgeRange do
                myxml.string(metadata_fields["5.7"], :language=> metadataLanguage)
              end
            end
            unless metadata_fields["5.8"].blank?
              myxml.difficulty do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["5.8"])
              end
            end
            unless metadata_fields["5.9"].blank?
              myxml.typicalLearningTime do
                myxml.duration(metadata_fields["5.9"])
                unless metadata["educational"]["typicallearningtime"]["description"].blank?
                  myxml.description(metadata["educational"]["typicallearningtime"]["description"])
                end
              end
            end
            unless metadata_fields["5.10"].blank?
              myxml.description do
                  myxml.string(metadata_fields["5.10"], loLanOpts)
              end
            end
            unless metadata_fields["5.11"].blank?
              myxml.language(metadata_fields["5.11"])                
            end
          end
        end

        unless metadata["rights"].blank?
          myxml.rights do
            unless metadata_fields["6.1"].blank?
              myxml.cost do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["6.1"])
              end
            end

            unless metadata_fields["6.2"].blank?
              myxml.copyrightAndOtherRestrictions do
                myxml.source(Metadata::Lom.schema)
                myxml.value(metadata_fields["6.2"])
              end
            end

            unless metadata_fields["6.3"].blank?
              myxml.description do
                myxml.string(metadata_fields["6.3"], :language=> metadataLanguage)
              end
            end
          end
        end

        unless metadata["relation"].blank?
          metadata["relation"] = [metadata["relation"]] unless metadata["relation"].is_a? Array
          metadata["relation"].each do |relation|
            myxml.relation do
              unless relation["kind"].blank? or !relation["kind"]["value"].is_a? String
                myxml.kind do
                  myxml.source(Metadata::Lom.schema)
                  myxml.value(relation["kind"]["value"])
                end
              end
              unless relation["resource"].blank?
                myxml.resource do
                  unless relation["resource"]["identifier"].blank?
                    myxml.identifier do
                      myxml.catalog(relation["resource"]["identifier"]["catalog"]) unless relation["resource"]["identifier"]["catalog"].blank?
                      myxml.entry(relation["resource"]["identifier"]["entry"]) unless relation["resource"]["identifier"]["entry"].blank?
                    end
                  end
                  unless relation["resource"]["description"].blank? or !relation["resource"]["description"]["value"].is_a? String
                    myxml.description do
                      myxml.source(Metadata::Lom.schema)
                      myxml.value(relation["resource"]["description"]["value"])
                    end
                  end
                end
              end
            end
          end
        end

        unless metadata["annotation"].blank?
        end

        unless metadata["classification"].blank?
        end

      end

      return myxml.target!
    end


    # LOM datatype Methods

    def getLangString(langString)
      return langString["string"] if (!langString.nil? and langString["string"].is_a? String)
      return langString["string"].join(", ") if (!langString.nil? and langString["string"].is_a? Array)
    end

    def getVocabularyItem(vocabulary)
      return vocabulary["value"] if (!vocabulary.nil? and vocabulary.is_a? Hash and vocabulary["value"].is_a? String)
      return vocabulary.select{|v| v["value"].is_a? String}.map{|v| v["value"]}.join(", ") if (!vocabulary.nil? and vocabulary.is_a? Array and !vocabulary.empty? and !vocabulary.select{|v| v["value"].is_a? String}.map{|v| v["value"]}.compact.blank? )
    end

    def getVCARD(vcard)
      if vcard.is_a? String
        vcard = vcard.gsub("&#xD;","\n")
        decoded_vcard = Vpim::Vcard.decode(vcard) rescue nil
        unless decoded_vcard.nil?
          decoded_vcard[0].name.fullname rescue nil
        end
      end
    end

    def getDatetime(datetime)
      datetime["datetime"] if (!datetime.nil? and datetime["datetime"].is_a? String)
    end

    def getDuration(duration)
      duration["duration"] if (!duration.nil? and duration["duration"].is_a? String)
    end

    def categories
      ["general","lifecycle","metametadata","technical","educational","rights","relation","annotation","classification"]
    end

  end

end