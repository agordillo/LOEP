class Lom < ActiveRecord::Base
  attr_accessible :profile

  belongs_to :lo

  validates :lo_id, :presence => true
  validates :profile, :presence => true

  def populate_from_url(metadata_url)
    require 'open-uri'
    begin
      doc = Nokogiri::HTML(open(metadata_url))
      lom = doc.at_xpath('//lom')
      self.profile = Hash.from_xml(lom.to_xml).to_json
    rescue
      self.populate_from_lo
    end
  end

  def populate_from_lo
    json = Hash.new
    json["lom"] = {}

    unless self.lo.nil?
      json["lom"]["general"] = {}
      json["lom"]["general"]["entry"] = self.lo.url unless self.lo.url.nil?
      json["lom"]["general"]["title"] = {"string" => self.lo.name } unless self.lo.name.blank?
      json["lom"]["general"]["language"] = self.lo.language.code unless self.lo.language.nil?
      json["lom"]["general"]["description"] = {"string" => self.lo.description } unless self.lo.description.blank?

      if self.lo.tag_list.length > 1
        json["lom"]["general"]["keyword"] = []
        self.lo.tag_list.each do |tag_name|
          json["lom"]["general"]["keyword"].push({"string" => tag_name})
        end
      end

      json["lom"]["metametadata"] = {}
      json["lom"]["metametadata"]["language"] = "en"
      json["lom"]["metametadata"]["metadataschema"] = "LOMv1.0"
      
      json["lom"]["technical"] = {}
      json["lom"]["technical"]["location"] = self.lo.url unless self.lo.url.nil?

      json["lom"]["educational"] = {}
      json["lom"]["educational"]["description"] = {"string" => self.lo.description } unless self.lo.description.blank?
      json["lom"]["educational"]["language"] = self.lo.language.code unless self.lo.language.nil?
    end

    self.profile = json.to_json
  end

  def metadata
    metadata = JSON.parse(self.profile)["lom"] rescue {}
    if metadata.nil?
      metadata = {}
    end
    return metadata
  end

  def metadata_fields
    metadata_fields = {}

    metadata = self.metadata

    #Category 1
    unless metadata["general"].nil?
      unless metadata["general"]["identifier"].nil?
        metadata_fields["1.1.1"] = metadata["general"]["identifier"]["catalog"] unless metadata["general"]["identifier"]["catalog"].blank?
        metadata_fields["1.1.2"] = metadata["general"]["identifier"]["entry"] unless metadata["general"]["identifier"]["entry"].blank?
      end
      metadata_fields["1.2"] = Lom.getLangString(metadata["general"]["title"]) unless Lom.getLangString(metadata["general"]["title"]).blank?
      metadata_fields["1.3"] = metadata["general"]["language"] unless metadata["general"]["language"].blank?
      metadata_fields["1.4"] = Lom.getLangString(metadata["general"]["description"]) unless Lom.getLangString(metadata["general"]["description"]).blank?
      metadata_fields["1.5"] = metadata["general"]["keyword"].map{|k| Lom.getLangString(k) }.compact.join(",") unless (!metadata["general"]["keyword"].is_a? Array or metadata["general"]["keyword"].map{|k| Lom.getLangString(k) }.compact.empty?)
      metadata_fields["1.6"] = Lom.getLangString(metadata["general"]["coverage"]) unless Lom.getLangString(metadata["general"]["coverage"]).blank?
      metadata_fields["1.7"] = Lom.getVocabularyItem(metadata["general"]["structure"]) unless Lom.getVocabularyItem(metadata["general"]["structure"]).blank?
      metadata_fields["1.8"] = Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]) unless Lom.getVocabularyItem(metadata["general"]["aggregationlevel"]).blank?
    end

    #Category 2
    unless metadata["lifecycle"].nil?
      metadata_fields["2.1"] = Lom.getLangString(metadata["lifecycle"]["version"]) unless metadata["lifecycle"]["version"].blank?
      metadata_fields["2.2"] = Lom.getVocabularyItem(metadata["lifecycle"]["status"]) unless metadata["lifecycle"]["status"].blank?
      if metadata["lifecycle"]["contribute"].is_a? Hash
        metadata["lifecycle"]["contribute"] = [metadata["lifecycle"]["contribute"]]
      end
      if metadata["lifecycle"]["contribute"].is_a? Array
        metadata_fields["2.3.1"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getVocabularyItem(c["role"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| c["role"]}.compact.blank?
        metadata_fields["2.3.2"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.blank?
        metadata_fields["2.3.3"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.blank?
      end
    end

    #Category 3
    unless metadata["metametadata"].nil?
      unless metadata["metametadata"]["identifier"].nil?
        metadata_fields["3.1.1"] = metadata["metametadata"]["identifier"]["catalog"] unless metadata["metametadata"]["identifier"]["catalog"].blank?
        metadata_fields["3.1.2"] = metadata["metametadata"]["identifier"]["entry"] unless metadata["metametadata"]["identifier"]["entry"].blank?
      end
      if metadata["metametadata"]["contribute"].is_a? Hash
        metadata["metametadata"]["contribute"] = [metadata["metametadata"]["contribute"]]
      end
      if metadata["metametadata"]["contribute"].is_a? Array
        metadata_fields["3.2.1"] = metadata["metametadata"]["contribute"].map{|c| Lom.getVocabularyItem(c["role"])}.compact.join(",") unless metadata["metametadata"]["contribute"].map{|c| c["role"]}.compact.blank?
        metadata_fields["3.2.2"] = metadata["metametadata"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.join(",") unless metadata["metametadata"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.blank?
        metadata_fields["3.2.3"] = metadata["metametadata"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.join(",") unless metadata["metametadata"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.blank?
      end
      metadata_fields["3.3"] = metadata["metametadata"]["metadataschema"] unless metadata["metametadata"]["metadataschema"].blank?
      metadata_fields["3.4"] = metadata["metametadata"]["language"] unless metadata["metametadata"]["language"].blank?
    end

    #Category 4
    unless metadata["technical"].nil?
      metadata_fields["4.1"] = metadata["technical"]["format"] unless metadata["technical"]["format"].blank?
      metadata_fields["4.2"] = metadata["technical"]["size"] unless metadata["technical"]["size"].blank?
      metadata_fields["4.3"] = metadata["technical"]["location"] unless metadata["technical"]["location"].blank?
      unless metadata["technical"]["requirement"].nil?
        if metadata["technical"]["requirement"].is_a? Hash
          metadata["technical"]["requirement"] = [metadata["technical"]["requirement"]]
        end
        if metadata["technical"]["requirement"].is_a? Array
          metadata["technical"]["requirement"] = metadata["technical"]["requirement"].reject{|mf| mf["orcomposite"].blank?}.map{|mf| mf["orcomposite"]}
          if metadata["technical"]["requirement"].length > 0
            metadata_fields["4.4.1.1"] = metadata["technical"]["requirement"].map{|c| Lom.getVocabularyItem(c["type"])}.compact.join(",") unless metadata["technical"]["requirement"].map{|c| c["type"]}.compact.blank?
            metadata_fields["4.4.1.2"] = metadata["technical"]["requirement"].map{|c| Lom.getVocabularyItem(c["name"])}.compact.join(",") unless metadata["technical"]["requirement"].map{|c| c["name"]}.compact.blank?
            metadata_fields["4.4.1.3"] = metadata["technical"]["requirement"].map{|c| c["minimumversion"]}.compact.join(",") unless metadata["technical"]["requirement"].map{|c| c["minimumversion"]}.compact.blank?
            metadata_fields["4.4.1.4"] = metadata["technical"]["requirement"].map{|c| c["maximumversion"]}.compact.join(",") unless metadata["technical"]["requirement"].map{|c| c["maximumversion"]}.compact.blank?
          end
        end
      end
      metadata_fields["4.5"] = Lom.getLangString(metadata["technical"]["installationremarks"]) unless Lom.getLangString(metadata["technical"]["installationremarks"]).blank?
      metadata_fields["4.6"] = Lom.getLangString(metadata["technical"]["otherplatformrequirements"]) unless Lom.getLangString(metadata["technical"]["otherplatformrequirements"]).blank?
      metadata_fields["4.7"] = Lom.getDuration(metadata["technical"]["duration"]) unless Lom.getDuration(metadata["technical"]["duration"]).blank?
    end

    #Category 5
    unless metadata["educational"].nil?
      metadata_fields["5.1"] = Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]) unless Lom.getVocabularyItem(metadata["educational"]["interactivitytype"]).blank?
      metadata_fields["5.2"] = Lom.getVocabularyItem(metadata["educational"]["learningresourcetype"]) unless Lom.getVocabularyItem(metadata["educational"]["learningresourcetype"]).blank?
      metadata_fields["5.3"] = Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]) unless Lom.getVocabularyItem(metadata["educational"]["interactivitylevel"]).blank?
      metadata_fields["5.4"] = Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]) unless Lom.getVocabularyItem(metadata["educational"]["semanticdensity"]).blank?
      metadata_fields["5.5"] = Lom.getVocabularyItem(metadata["educational"]["intendedenduserrole"]) unless Lom.getVocabularyItem(metadata["educational"]["intendedenduserrole"]).blank?
      metadata_fields["5.6"] = Lom.getVocabularyItem(metadata["educational"]["context"]) unless Lom.getVocabularyItem(metadata["educational"]["context"]).blank?
      metadata_fields["5.7"] = Lom.getLangString(metadata["educational"]["typicalagerange"]) unless Lom.getLangString(metadata["educational"]["typicalagerange"]).blank?
      metadata_fields["5.8"] = Lom.getVocabularyItem(metadata["educational"]["difficulty"]) unless Lom.getVocabularyItem(metadata["educational"]["difficulty"]).blank?
      metadata_fields["5.9"] = Lom.getDuration(metadata["educational"]["typicallearningtime"]) unless Lom.getDuration(metadata["educational"]["typicallearningtime"]).blank?
      metadata_fields["5.10"] = Lom.getLangString(metadata["educational"]["description"]) unless Lom.getLangString(metadata["educational"]["description"]).blank?
      metadata_fields["5.11"] = metadata["educational"]["language"] unless metadata["educational"]["language"].blank?
    end

    #Category 6
    unless metadata["rights"].nil?
      metadata_fields["6.1"] = Lom.getVocabularyItem(metadata["rights"]["cost"]) unless Lom.getVocabularyItem(metadata["rights"]["cost"]).blank?
      metadata_fields["6.2"] = Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]) unless Lom.getVocabularyItem(metadata["rights"]["copyrightandotherrestrictions"]).blank?
      metadata_fields["6.3"] = Lom.getLangString(metadata["rights"]["description"]) unless Lom.getLangString(metadata["rights"]["description"]).blank?
    end

    #Category 7
    unless metadata["relation"].nil?
      if metadata["relation"].is_a? Hash
        metadata["relation"] = [metadata["relation"]]
      end
      metadata_fields["7.1"] = metadata["relation"].map{|c| Lom.getVocabularyItem(c["kind"])}.compact.join(",") unless metadata["relation"].map{|c| c["kind"]}.compact.blank?
      metadataResources = metadata["relation"].reject{|mr| mr["resource"].nil?}.map{|mr| mr["resource"]}
      unless metadataResources.empty?
        metadataIdentifiers = metadataResources.reject{|mr| mr["identifier"].nil?}.map{|mr| mr["identifier"]}
        unless metadataIdentifiers.empty?
          metadata_fields["7.2.1.1"] = metadataIdentifiers.map{|c| c["catalog"]}.compact.join(",") unless metadataIdentifiers.map{|c| c["catalog"]}.compact.blank?
          metadata_fields["7.2.1.2"] = metadataIdentifiers.map{|c| c["entry"]}.compact.join(",") unless metadataIdentifiers.map{|c| c["entry"]}.compact.blank?
        end
        metadata_fields["7.2.2"] = metadataResources.map{|c| Lom.getLangString(c["description"])}.compact.join(",") unless metadataResources.map{|c| Lom.getLangString(c["description"])}.compact.blank?
      end
    end

    #Category 8
    unless metadata["annotation"].nil?
      if metadata["annotation"].is_a? Hash
        metadata["annotation"] = [metadata["annotation"]]
      end
      metadata_fields["8.1"] = metadata["annotation"].map{|c| Lom.getVCARD(c["entity"])}.compact.join(",") unless metadata["annotation"].map{|c| Lom.getVCARD(c["entity"])}.compact.blank?
      metadata_fields["8.2"] = metadata["annotation"].map{|c| Lom.getDateTime(c["date"])}.compact.join(",") unless metadata["annotation"].map{|c| Lom.getDateTime(c["date"])}.compact.blank?
      metadata_fields["8.3"] = metadata["annotation"].map{|c| Lom.getLangString(c["description"])}.compact.join(",") unless metadata["annotation"].map{|c| Lom.getLangString(c["description"])}.compact.blank?
    end

    #Category 9
    unless metadata["classification"].nil?
      metadata_fields["9.1"] = Lom.getVocabularyItem(metadata["classification"]["purpose"]) unless Lom.getVocabularyItem(metadata["classification"]["purpose"]).blank?
      unless metadata["classification"]["taxonpath"].nil?
        if metadata["classification"]["taxonpath"].is_a? Hash
          metadata["classification"]["taxonpath"] = [metadata["classification"]["taxonpath"]]
        end
        metadata_fields["9.2.1"] = metadata["classification"]["taxonpath"].map{|c| Lom.getLangString(c["source"])}.compact.join(",") unless metadata["classification"]["taxonpath"].map{|c| Lom.getLangString(c["source"])}.compact.blank?
        metadataTaxons = metadata["classification"]["taxonpath"].reject{|ct| ct["taxon"].nil?}.map{|ct| ct["taxon"]}
        unless metadataTaxons.empty?
          metadata_fields["9.2.2.1"] = metadataTaxons.map{|c| c["id"]}.compact.join(",") unless metadataTaxons.map{|c| c["id"]}.compact.blank?
          metadata_fields["9.2.2.2"] = metadataTaxons.map{|c| Lom.getLangString(c["entry"])}.compact.join(",") unless metadataTaxons.map{|c| Lom.getLangString(c["entry"])}.compact.blank?
        end
      end
      metadata_fields["9.3"] = Lom.getLangString(metadata["classification"]["description"]) unless Lom.getLangString(metadata["classification"]["description"]).blank?
      metadata_fields["9.4"] = metadata["classification"]["keyword"].map{|k| Lom.getLangString(k)}.compact.join(",") unless (!metadata["classification"]["keyword"].is_a? Array or metadata["classification"]["keyword"].map{|k| Lom.getLangString(k)}.compact.empty?)
    end

    metadata_fields
  end


  # Class Methods

  def self.getLangString(langString)
    return langString["string"] if (!langString.nil? and langString["string"].is_a? String)
    return langString["string"].join(",") if (!langString.nil? and langString["string"].is_a? Array)
  end

  def self.getVocabularyItem(vocabulary)
    return vocabulary["value"] if (!vocabulary.nil? and vocabulary.is_a? Hash and vocabulary["value"].is_a? String)
    return vocabulary.select{|v| v["value"].is_a? String}.map{|v| v["value"]}.join(",") if (!vocabulary.nil? and vocabulary.is_a? Array and !vocabulary.empty? and !vocabulary.select{|v| v["value"].is_a? String}.map{|v| v["value"]}.compact.blank? )
  end

  def self.getVCARD(vcard)
    if vcard.is_a? String
      vcard = vcard.gsub("&#xD;","\n")
      decoded_vcard = Vpim::Vcard.decode(vcard) rescue nil
      unless decoded_vcard.nil?
        decoded_vcard[0].name.fullname rescue nil
      end
    end
  end

  def self.getDatetime(datetime)
    datetime["datetime"] if (!datetime.nil? and datetime["datetime"].is_a? String)
  end

  def self.getDuration(duration)
    duration["duration"] if (!duration.nil? and duration["duration"].is_a? String)
  end

  def self.categories
    ["general","lifecycle","metametadata","technical","educational","rights","relation","annotation","classification"]
  end

end