#LOEM Weighted Arithmetic Mean (LOEM WAM)
#Weighted Arithmetic Mean of LOEM items.

class Metrics::LOEMWAM < Metric
  # this is for Metrics with type=LOEMWAM
  #Override methods here

  def self.getLoScore(items,evaluations)
    loScore = 0
    items.each_with_index do |iScore,i|
      loScore = loScore + ((iScore-1) * itemWeights[i])
    end
    loScore = 5.to_f * loScore.to_f

    return loScore
  end

end