# encoding: utf-8

class Metrics::QinteractionPermanency < Metrics::QinteractionItem

  def self.getScoreForInteractions(interactions={})
    [1,interactions["permanency_rate"]["average_value"]/threshold].min*10 rescue 0
  end

end