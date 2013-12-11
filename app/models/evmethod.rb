class Evmethod < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :assignments

  validates :name,
  :presence => true,
  :length => { :in => 2..255 },
  :uniqueness => {
    :case_sensitive => false
  }
end
