class Score < ActiveRecord::Base
  attr_accessible :metric_id, :lo_id, :value

  belongs_to :lo
  belongs_to :metric

  validates :metric_id, :presence => true
  validates :lo_id, :presence => true
  validates :value, :presence => true
  validate :duplicated_score

  def duplicated_score
    if Score.where(:id => !self.id, :metric_id => self.metric.id, :lo_id => self.lo_id).length > 0
      errors.add(:duplicated_score, ": This score already exists.")
    else
      true
    end
  end

  before_validation :checkScoreBeforeSave

  def updateScore
    self.value = self.metric.class.getScoreForLo(self.lo)
    self.save!
  end


#-------------------------------------------------------------------------------------

  private

  def checkScoreBeforeSave
    if self.value.nil?
      self.value = self.metric.class.getScoreForLo(self.lo)
    end
  end

end
