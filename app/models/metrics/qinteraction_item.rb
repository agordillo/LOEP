class Metrics::QinteractionItem < Metric

  def self.getLoScore(evData)
    evData[self.getInstance.evmethods.first.name][:items][getItemNumber] rescue nil
  end

  def self.getItemNumber
    Evaluations::Qinteraction.getItemsWithType("numeric").each_with_index do |item,index|
      return index if item[:metric] == self.name
    end
    nil
  end

  def getScoreForLo(lo)
    self.class.getScoreForLo(lo)
  end

  def self.getScoreForLo(lo)
    loInteraction = lo.getInteraction
    return nil if loInteraction.nil?
    interactions = loInteraction.extended_attributes
    threshold = thresholds(lo.repository)[self.name]
    score = threshold.blank? ? getScoreForInteractions(interactions) : getScoreForInteractions(interactions,threshold)
    ([[score,0].max,10].min).round(2)
  end

  def self.getScoreForInteractions(interactions={})
    #Override me
  end

  def self.thresholds(repository=nil)
    thresholdValues = LOEP::Application::config.respond_to?("interaction_thresholds") ? LOEP::Application::config.interaction_thresholds : {};
    unless thresholdValues[repository].blank? or (repository.blank? and LOEP::Application::config.repositories.length > 1)
      thresholdValues = thresholdValues[repository]
    else
      thresholdValues = {} #Use default thresholds
      # thresholdValues = thresholdValues[nil] unless thresholdValues[nil].blank? #Use max thresholds in LOEP
    end
    thresholds = {
      "Metrics::QinteractionTime" => thresholdValues["Metrics::QinteractionTime"],
      "Metrics::QinteractionPermanency" => thresholdValues["Metrics::QinteractionPermanency"],
      "Metrics::QinteractionClickFrequency" => thresholdValues["Metrics::QinteractionClickFrequency"]
    }
    thresholds.map{|k,v| 
      thresholds[k] = (v.blank? ? v : v.to_f)
    }
    thresholds
  end

end