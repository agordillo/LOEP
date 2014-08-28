class Metric < ActiveRecord::Base
  attr_accessible :name

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  has_many :scores, :dependent => :destroy
  has_and_belongs_to_many :evmethods
  
  def self.allc
    Metric.where("type in (?)",LOEP::Application.config.metrics.map{|m| m.class.name})
  end

end
