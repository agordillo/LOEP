# encoding: utf-8

class Metrics::QinteractionClickFrequency < Metrics::QinteractionItem

  def self.getScoreForInteractions(interactions={},threshold=6)
    [1,(interactions["nclicks"]["average_value"]/(interactions["tlo"]["average_value"]/60))/threshold].min*10 rescue 0
  end

end