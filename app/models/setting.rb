class Setting < ActiveRecord::Base
  validates :key, uniqueness: { :scope => :repository, :case_sensitive => false }, :presence => true
  validates :value, :presence => true
end
