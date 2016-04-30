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
    ([[getScoreForInteractions(interactions),0].max,10].min).round(2)
  end

  def self.getScoreForInteractions(interactions={})
    #Override me
  end

  def self.threshold
    {
      "Metrics::QinteractionTime" => 524,
      "Metrics::QinteractionPermanency" => 73,
      "Metrics::QinteractionClickFrequency" => 18
    }[self.name]
  end

end