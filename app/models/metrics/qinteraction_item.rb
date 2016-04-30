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
    return nil if lo.lo_interaction.nil?
    interactions = lo.lo_interaction.extended_attributes
    ([[getScoreForInteractions(interactions,thresholds(lo.repository)[self.name]),0].max,10].min).round(2)
  end

  def self.getScoreForInteractions(interactions={})
    #Override me
  end

  def self.thresholds(repository=nil)
    thresholdValues = LOEP::Application::config.respond_to?("interaction_thresholds") ? LOEP::Application::config.interaction_thresholds : {};
    thresholdValues = thresholdValues[repository] unless thresholdValues[repository].blank?
    thresholdValues = thresholdValues[nil] if thresholdValues.blank? and !thresholdValues[nil].blank?
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