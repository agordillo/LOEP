# encoding: utf-8

class MetadataGraphLink < ActiveRecord::Base
  attr_accessible :metadata_id, :keyword, :repository

  belongs_to :metadata

  validates :metadata_id, :presence => true
  validates :keyword, :presence => true

  validate :duplicates

  def duplicates
    if self.new_record?
      mgl = MetadataGraphLink.where(:metadata_id => self.metadata_id, :keyword => self.keyword).first
      if !mgl.nil? and mgl.keyword==self.keyword
        return errors[:base] << "Duplicated MetadataGraphLink record (same metadadata record and keyword)"
      end
    end
    true
  end

  before_validation :normalize_keyword
  before_validation :fill_data

  def self.getLinksForKeywords(keywords,options={})
    return 0 unless keywords.is_a? Array
    query = {:keyword => UtilsTfidf.normalizeArray(keywords)}
    query = query.merge({:repository => options[:repository]}) unless options[:repository].blank?
    # metadataGraphLinks.map{|gl| gl.metadata_id}.uniq.length
    MetadataGraphLink.where(query).group(:metadata_id).length
  end


  private

  def normalize_keyword
    self.keyword = UtilsTfidf.normalizeText(self.keyword) if self.keyword.is_a? String
  end

  def fill_data
    return if self.metadata_id.blank?
    metadata = Metadata.find_by_id(metadata_id)
    self.repository = metadata.lo.repository unless metadata.nil? or metadata.lo.nil? or metadata.lo.repository.blank?
  end

end