#LORI Logarithmic Metric

class Metrics::LORILOG < Metrics::LORIORT
  # this is for Metrics with type=LORILOG
  #Override methods here

  def self.getOverallScore(scorePWAM,scoreTWAM)
    scorePWAM.to_f * Math.log(AParam()*scoreTWAM+1,Math::E).to_f / Math.log(10*AParam()+1,Math::E).to_f
  end

  def self.AParam
    2
  end

end