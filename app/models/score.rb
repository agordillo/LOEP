class Score < ActiveRecord::Base
  attr_accessible :lo_id, :metric_id, :value

  validates :lo_id, :presence => true
  validates :metric_id, :presence => true
  validates :value, :presence => true

  belongs_to :lo
  belongs_to :metric

end
