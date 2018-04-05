class LoepSetting < ActiveRecord::Base
  validates :key, uniqueness: { :case_sensitive => false }, :presence => true
  validates :value, :presence => true
end