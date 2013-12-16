class App < ActiveRecord::Base
  attr_accessible :name, :auth_token

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :auth_token,
  :presence => true,
  :uniqueness => true

end
