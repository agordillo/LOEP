# encoding: utf-8

class MetadataField < ActiveRecord::Base
  attr_accessible :name, :field_type, :value, :n, :metadata_id, :repository

  belongs_to :metadata

  validates :name, :presence => true
  validates :value, :presence => true
  validates :n, :presence => true
  validates :metadata_id, :presence => true

  validate :duplicates

  def duplicates
    if self.new_record?
      unless self.field_type == "max"
        if MetadataField.where(:name => self.name, :metadata_id => self.metadata_id, :value => self.value).length > 0
          return errors[:base] << "Duplicated MetadataField record (same name, metadata record and value)"
        end
      else
        if MetadataField.where(:name => self.name, :repository => self.repository).length > 0
          return errors[:base] << "Duplicated MetadataField record of a max value (same name and repository)"
        end
      end
    end
    true
  end

  before_validation :fill_data


  #Methods

  def self.getMaxRecords
    MetadataField.where("field_type in (?)", ["max"])
  end

  private

  def fill_data
    unless self.metadata_id.blank?
      metadata = Metadata.find_by_id(metadata_id)
      unless metadata.nil? or metadata.lo.nil? or metadata.lo.repository.blank?
        self.repository = metadata.lo.repository
      end
    end
  end

end