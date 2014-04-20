#LORI Root Square Metric

class Metrics::LORISQRT < Metrics::LORIORT
  #this is for Metrics with type=LORISQRT
  #Override methods here

  def self.getOverallScore(scorePWAM,scoreTWAM)
    Math.sqrt(scorePWAM.to_f * scoreTWAM.to_f).to_f
  end

end