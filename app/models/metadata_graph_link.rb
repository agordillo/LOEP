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

  before_validation :lowercase_keyword
  before_validation :fill_data

  def self.getLinksForKeywords(keywords,options={})
    return 0 unless keywords.is_a? Array
    keywords = keywords.reject{|k| k.blank?}.map{|k| k.downcase}.uniq
    query = {:keyword => keywords}
    unless options[:repository].blank?
      query = query.merge({:repository => options[:repository]})
    end
    MetadataGraphLink.where(query).group(:metadata_id).length
  end

  private

  def lowercase_keyword
    self.keyword = self.keyword.downcase if self.keyword.is_a? String
  end

  def fill_data
    unless self.metadata_id.blank?
      metadata = Metadata.find_by_id(metadata_id)
      unless metadata.nil? or metadata.lo.nil? or metadata.lo.repository.blank?
        self.repository = metadata.lo.repository
      end
    end
  end

end