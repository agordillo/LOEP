class Evaluation < ActiveRecord::Base
  attr_accessible :assignment_id, :completed_at, :evmethod_id, :lo_id, :user_id

  belongs_to :user
  belongs_to :lo
  belongs_to :evmethod
  belongs_to :assignment #optional

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :evmethod_id,
  :presence => true
  
end
