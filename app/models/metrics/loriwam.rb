#Weighted arithmetic mean of LORI items.
#Use the weights obtained from the LORI survey

class Metrics::LORIWAM < Metric
  # this is for Metrics with type=LORIWAM
  #Override methods here

  def create
    super
  end

  def self.getScoreForLos(los)
    scores = Hash.new
    los.each do |lo|
      scores[lo.id.to_s] = getScoreForLo(lo)
    end
    scores
  end

  def self.getScoreForLo(lo)
    evaluations = lo.evaluations.where(:evmethod_id => Evmethod.find_by_name("LORI v1.5").id)
    # evaluations = lo.evaluations.select{|ev| self.evmethods.include? ev.evmethod }

    if evaluations.length === 0
      return nil
    end

    loScore = 0
    9.times do |i|
      validEvaluations = Evaluation.getValidEvaluationsForItem(evaluations,i+1)
      if validEvaluations.length == 0
        #Means that this item has not been evaluated in any evaluation
        #All evaluations had leave this item in blank
        return nil
      end
      iScore = validEvaluations.average("item"+(i+1).to_s).to_f
      loScore = loScore + ((iScore-1) * itemWeights[i])
    end
    loScore = 5/2.to_f * loScore.to_f
    loScore = ([[loScore,0].max,10].min).round(2)
  end

  def self.itemWeights
    [
      BigDecimal(0.1724,4),
      BigDecimal(0.1207,4),
      BigDecimal(0.1138,4),
      BigDecimal(0.1414,4),
      BigDecimal(0.1379,4),
      BigDecimal(0.1034,4),
      BigDecimal(0.0655,4),
      BigDecimal(0.0759,4),
      BigDecimal(0.069,4)
    ]
  end

end