#LORI Orthogonal Metric

class Metrics::LORIORT < Metric
  # this is for Metrics with type=LORIORT
  #Override methods here

  def self.getLoScore(items,evaluations)
    scores = getLORIPTScores(items)
    if scores.nil? or scores[0].nil? or scores[1].nil?
      return nil
    end
    loScore = getOverallScore(scores[0],scores[1])
    return loScore
  end

  def self.getLORIPTScores(items)
    loScorePWAM = 0
    loScoreTWAM = 0

    items.each_with_index do |iScore,i|
      if (i+1)<7
        #Items 1 to 6
        loScorePWAM = loScorePWAM + ((iScore-1) * Metrics::LORIPWAM.itemWeights[i])
      else
        #Items 7 to 9
        loScoreTWAM = loScoreTWAM + ((iScore-1) * Metrics::LORITWAM.itemWeights[i])
      end
    end

    loScorePWAM = 5/2.to_f * loScorePWAM.to_f
    loScorePWAM = ([[loScorePWAM,0].max,10].min).round(2)

    loScoreTWAM = 5/2.to_f * loScoreTWAM.to_f
    loScoreTWAM = ([[loScoreTWAM,0].max,10].min).round(2)

    return [loScorePWAM,loScoreTWAM]
  end

  def self.getOverallScore(scorePWAM,scoreTWAM)
    BigDecimal(0.707107,6) * Math.sqrt(scorePWAM**2 + scoreTWAM**2)
    # BigDecimal(0.707107,6) * Math.hypot(scorePWAM, scoreTWAM)
  end

end