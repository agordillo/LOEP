# encoding: utf-8

class Metrics::QinteractionTime < Metrics::QinteractionItem

  def self.getScoreForInteractions(interactions={})
  	# [1,interactions["tlo"]["average_value"]/500].min*10
    10
  end

end