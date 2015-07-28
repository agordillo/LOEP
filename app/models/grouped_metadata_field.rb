# encoding: utf-8

class GroupedMetadataField < ActiveRecord::Base
  attr_accessible :name, :field_type, :value, :n, :repository

  belongs_to :metadata

  validates :name, :presence => true
  validates :n, :presence => true

  validate :duplicates

  def duplicates
    if self.new_record?
      gmf = GroupedMetadataField.where(:name => self.name, :value => self.value, :repository => self.repository).first
      if !gmf.nil? and gmf.value==self.value
        return errors[:base] << "Duplicated MetadataField record (same name, repository and value)"
      end
    end
    true
  end

  before_validation :lowercase_value


  private

  def lowercase_value
    self.value = self.value.downcase if self.value.is_a? String
  end

end