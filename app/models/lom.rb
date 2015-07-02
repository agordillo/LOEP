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
    end
  end

  def populate_from_lo
    return if self.lo.nil?

    json = Hash.new
    json["lom"] = {}

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

    self.profile = json.to_json
  end

  def metadata
    metadata = JSON.parse(self.profile)["lom"] rescue nil
    unless metadata.nil?
      metadata
    end
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
      if metadata["lifecycle"]["contribute"].is_a? Array
        metadata_fields["2.3.1"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getVocabularyItem(c["role"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| c["role"]}.compact.blank?
        metadata_fields["2.3.2"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| Lom.getVCARD(c["entity"])}.compact.blank?
        metadata_fields["2.3.3"] = metadata["lifecycle"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.join(",") unless metadata["lifecycle"]["contribute"].map{|c| Lom.getDatetime(c["date"])}.compact.blank?
      end
    end

    #Category 3
    unless metadata["metametadata"].nil?
      #TODO
    end

    metadata_fields
  end

  def self.getLangString(langString)
    langString["string"] if (!langString.nil? and langString["string"].is_a? String)
  end

  def self.getVocabularyItem(vocabulary)
    vocabulary["value"] if (!vocabulary.nil? and vocabulary["value"].is_a? String)
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

  def self.categories
    ["general","lifecycle","metametadata","technical","educational","rights","relation","annotation","classification"]
  end

end