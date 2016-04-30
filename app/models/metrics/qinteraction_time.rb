# encoding: utf-8

class Metrics::QinteractionTime < Metrics::QinteractionItem

  def self.getScoreForInteractions(interactions={})
    [1,interactions["tlo"]["average_value"]/threshold].min*10 rescue 0
  end

end