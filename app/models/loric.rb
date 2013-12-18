class Loric < ActiveRecord::Base
  attr_accessible :user_id, :item1, :item2, :item3, :item4, :item5, :item6, :item7, :item8, :item9, :comments
  belongs_to :user

  after_save :update_user

  validates :user_id, :presence => true
  validates :item1, :presence => true
  validates :item2, :presence => true
  validates :item3, :presence => true
  validates :item4, :presence => true
  validates :item5, :presence => true
  validates :item6, :presence => true
  validates :item7, :presence => true
  validates :item8, :presence => true
  validates :item9, :presence => true

  def update_user
  	user = User.find(self.user_id)
  	user.loric_id = self.id
  	user.save(:validate => false)
  end

end
