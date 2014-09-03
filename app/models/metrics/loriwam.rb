#LORI Weighted Arithmetic Mean (LORI WAM)
#Weighted Arithmetic Mean of LORI items.

class Metrics::LORIWAM < Metric
  # this is for Metrics with type=LORIWAM
  #Override methods here

  def self.getLoScore(items,evaluations)
    loScore = 0
    items.each_with_index do |iScore,i|
      loScore = loScore + ((iScore-1) * itemWeights[i])
    end
    loScore = 5/2.to_f * loScore.to_f

    return loScore
  end

end