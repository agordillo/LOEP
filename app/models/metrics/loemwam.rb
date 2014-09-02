#LOEM Weighted Arithmetic Mean (LOEM WAM)
#Weighted Arithmetic Mean of LOEM items.

class Metrics::LOEMWAM < Metric
  # this is for Metrics with type=LOEMWAM
  #Override methods here

  def self.getScoreForEvaluations(evaluations)
    loScore = 0
    17.times do |i|
      validEvaluations = Evaluation.getValidEvaluationsForItem(evaluations,i+1)
      if validEvaluations.length == 0
        #Means that this item has not been evaluated in any evaluation
        #All evaluations had leave this item in blank
        return nil
      end
      iScore = validEvaluations.average("item"+(i+1).to_s).to_f
      loScore = loScore + ((iScore-1) * itemWeights[i])
    end
    loScore = 5.to_f * loScore.to_f
    loScore = ([[loScore,0].max,10].min).round(2)
  end

end