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
        mf = MetadataField.where(:name => self.name, :metadata_id => self.metadata_id, :value => self.value).first
        if !mf.nil? and mf.value==self.value
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

  before_validation :lowercase_value
  before_validation :fill_data


  #Methods

  def self.getMaxRecords
    MetadataField.where("field_type in (?)", ["max"])
  end

  # Store and update max values of MetadataFields
  def self.updateMax(key,candidateValue,options)
    allMaxInstances =  MetadataField.where(:name => key + "_max")
    unless options[:repository].blank?
      allMaxInstances =  allMaxInstances.where(:repository => options[:repository])
    end
    metadataFieldMaxValueInstance = allMaxInstances.first

    if metadataFieldMaxValueInstance.nil?
      metadataFieldMaxValueInstance = MetadataField.new({:name => key + "_max", :field_type => "max", :value => candidateValue, :n => 1, :metadata_id => -1, :repository => options[:repository]})
      metadataFieldMaxValueInstance.save!
    else
      if metadataFieldMaxValueInstance.repository == options[:repository]
        if candidateValue > metadataFieldMaxValueInstance.value.to_f
          #Update
          metadataFieldMaxValueInstance.value = candidateValue
          metadataFieldMaxValueInstance.save!
        end
      end
    end
    #Return max value
    metadataFieldMaxValueInstance.value
  end


  private

  def lowercase_value
    self.value = self.value.downcase if self.value.is_a? String
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