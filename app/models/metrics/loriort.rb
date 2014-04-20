#LORI Orthogonal Metric

class Metrics::LORIORT < Metric
  # this is for Metrics with type=LORIORT
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
    scores = getLORIPTScores(lo)
    if scores.nil? or scores[0].nil? or scores[1].nil?
      return nil
    end
    loScore = ([[getOverallScore(scores[0],scores[1]),0].max,10].min).round(2)
  end

  def self.getLORIPTScores(lo)
    evaluations = lo.evaluations.where(:evmethod_id => Evmethod.find_by_name("LORI v1.5").id)
    # evaluations = lo.evaluations.select{|ev| self.evmethods.include? ev.evmethod }

    if evaluations.length === 0
      return nil
    end

    loScorePWAM = 0
    loScoreTWAM = 0
    9.times do |i|
      validEvaluations = Evaluation.getValidEvaluationsForItem(evaluations,i+1)
      if validEvaluations.length == 0
        #Means that this item has not been evaluated in any evaluation
        #All evaluations had leave this item in blank
        return nil
      end
      iScore = validEvaluations.average("item"+(i+1).to_s).to_f
      if (i+1)<7
        #Items 1 a 6
        loScorePWAM = loScorePWAM + ((iScore-1) * Metrics::LORIPWAM.itemWeights[i])
      else
        #Items 7 a 9
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

  #Optional
  def self.getScoreForEvaluation(evaluation)
    scores = getLORIPTScoresForEvaluation(evaluation)
    if scores.nil? or scores[0].nil? or scores[1].nil?
      return nil
    end
    loScore = ([[getOverallScore(scores[0],scores[1]),0].max,10].min).round(2)
  end

  def self.getLORIPTScoresForEvaluation(evaluation)
    loScorePWAM = 0
    loScoreTWAM = 0
    9.times do |i|
      iScore = evaluation.send("item"+(i+1).to_s)
      if iScore.nil?
        return nil
      end

      if (i+1)<7
        #Items 1 a 6
        loScorePWAM = loScorePWAM + ((iScore-1) * Metrics::LORIPWAM.itemWeights[i])
      else
        #Items 7 a 9
        loScoreTWAM = loScoreTWAM + ((iScore-1) * Metrics::LORITWAM.itemWeights[i])
      end
    end
    
    loScorePWAM = 5/2.to_f * loScorePWAM.to_f
    loScorePWAM = ([[loScorePWAM,0].max,10].min).round(2)

    loScoreTWAM = 5/2.to_f * loScoreTWAM.to_f
    loScoreTWAM = ([[loScoreTWAM,0].max,10].min).round(2)

    return [loScorePWAM,loScoreTWAM]
  end

end