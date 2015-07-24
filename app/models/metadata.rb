class Metadata < ActiveRecord::Base
  attr_accessible :schema, :content

  belongs_to :lo

  validates :lo_id, :presence => true
  validates :schema, :presence => true
  validates :content, :presence => true

  def update
    unless self.lo.nil?
      unless self.lo.metadata_url.blank?
        #Save metadata from url
        self.populate_from_url
      else
        self.populate_from_lo
      end

      if self.new_record?
        self.save
      else
        self.update_column :content, self.content
        self.update_column :lom_content, self.lom_content
        self.update_column :updated_at, Time.now
      end
    end
  end

  def populate_from_url(metadata_url=nil)
    metadata_url = self.lo.metadata_url if metadata_url.blank?
    require 'open-uri'
    begin
      metadata_content = nil
      doc = Nokogiri::HTML(open(metadata_url,:read_timeout => 10))
      
      if Metadata::Lom.compliant?(doc)
        self.schema = Metadata::Lom.schema
        metadata_content = Metadata::Lom.getContent(doc)
      elsif Metadata::Dc.compliant?(doc)
        self.schema = Metadata::Dc.schema
        metadata_content = Metadata::Dc.getContent(doc)
      else
        self.schema = "Unknown"
        metadata_content = doc
      end

      metadata_content = Hash.from_xml_with_attributes(metadata_content)
      self.content = metadata_content.to_json

      #Translation to LOM
      if self.schema === Metadata::Lom.schema
        #No need to translate. Rebuild LOM.
        self.lom_content = Metadata::Lom.build_metadata_json(metadata_content).to_json
      elsif self.schema != "Unknown"
        # TODO: translations.
        # Generate self.lom_content from self.content in other metadata schemas
        # case self.schema
        # when Metadata::Dc.schema
        #   #Translate DC to LOM.
        # else
        # end
      end

    rescue
      populate_from_lo
    end
  end

  def populate_from_lo
    #Save metadata as LOMv1.0
    self.schema = Metadata::Lom.schema

    metadata = Hash.new
    metadata["lom"] = {}

    unless self.lo.nil?
      metadata["lom"]["general"] = {}
      metadata["lom"]["general"]["entry"] = {"value" => self.lo.url} unless self.lo.url.nil?
      metadata["lom"]["general"]["title"] = {"string" => {"value" => self.lo.name}} unless self.lo.name.blank?
      metadata["lom"]["general"]["language"] = {"value" => self.lo.language.code} unless self.lo.language.nil?
      metadata["lom"]["general"]["description"] = {"string" => {"value" => self.lo.description}} unless self.lo.description.blank?

      if self.lo.tag_list.length > 1
        metadata["lom"]["general"]["keyword"] = []
        self.lo.tag_list.each do |tag_name|
          metadata["lom"]["general"]["keyword"].push({"string" => {"value" => tag_name}})
        end
      end

      metadata["lom"]["metametadata"] = {}
      metadata["lom"]["metametadata"]["language"] = {"value" => "en"}
      metadata["lom"]["metametadata"]["metadataschema"] = {"value" => "LOMv1.0"}
      
      metadata["lom"]["technical"] = {}
      metadata["lom"]["technical"]["location"] = {"value" => self.lo.url} unless self.lo.url.nil?

      metadata["lom"]["educational"] = {}
      metadata["lom"]["educational"]["description"] = {"string" => {"value" => self.lo.description}} unless self.lo.description.blank?
      metadata["lom"]["educational"]["language"] = {"value" => self.lo.language.code} unless self.lo.language.nil?
    end

    self.content = metadata.to_json
    self.lom_content = self.content
  end

  def getMetadata(options={})
    options = {:format => "json", :schema => Metadata::Lom.schema }.merge(options)

    case options[:format]
    when "json"
      return metadata_json(options)
    when "xml"
      return metadata_xml(options)
    else
      return nil
    end
  end

  def metadata_json(options)
    case options[:schema]
    when  Metadata::Lom.schema
      if options[:fields]===true
        return Metadata::Lom.metadata_fields(self)
      else
        return Metadata::Lom.metadata_json(self)
      end
    when Metadata::Dc.schema
      return Metadata::Dc.metadata_json(self)
    else
      return {}
    end
  end

  def metadata_xml(options)
    case options[:schema]
    when  Metadata::Lom.schema
      return Metadata::Lom.metadata_xml(self)
    when Metadata::Dc.schema
      return Metadata::Dc.metadata_xml(self)
    else
      return Metadata.getEmptyXml
    end
  end

  def self.getEmptyXml
    require 'builder'
    xmlMetadata = ::Builder::XmlMarkup.new(:indent => 2)
    xmlMetadata.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    xmlMetadata.error("Learning Object Metadata record not found")
    return xmlMetadata.target!
  end

end