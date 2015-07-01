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
    json["lom"]["general"]["title"] = self.lo.name unless self.lo.name.blank?
    json["lom"]["general"]["description"] = self.lo.description unless self.lo.description.blank?

    if self.lo.tag_list.length > 1
      json["lom"]["general"]["keywords"] = []
      self.lo.tag_list.each do |tag_name|
        json["lom"]["general"]["keywords"].push({"string" => tag_name})
      end
    end

    self.profile = json.to_json
  end

  def metadata
    metadata = JSON.parse(self.profile)["lom"] rescue nil
    unless metadata.nil?
      metadata
    end
  end

end