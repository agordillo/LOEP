class Score < ActiveRecord::Base
  attr_accessible :metric_id, :lo_id, :value

  belongs_to :lo
  belongs_to :metric

  validates :metric_id, :presence => true
  validates :lo_id, :presence => true
  validates :value, :presence => true
  validate :duplicated_score

  def duplicated_score
    if self.id.nil?
      scores = Score.where(:metric_id => self.metric.id, :lo_id => self.lo_id)
      if scores.length > 0
        errors.add(:duplicated_score, ": " + I18n.t("scores.message.error.duplicated"))
      else
        true
      end
    else
      #Updating an existing resource
      true
    end
  end

  before_validation :checkScoreBeforeSave


  def automatic?
    self.metric.automatic?
  end

  #-------------------------------------------------------------------------------------

  private

  def checkScoreBeforeSave
    if self.value.nil?
      loScore = self.metric.getScoreForLo(self.lo)
      self.value = loScore unless loScore.nil?
    end
  end

end
