#LORI WAM with CURRENT collected weights (LORI WAM CCW)
#Use the current weights obtained from the LORI survey

class Metrics::LORIWAM3 < Metrics::LORIWAM
  # this is for Metrics with type=LORIWAM3

  def self.itemWeights
    getItemWeightsFromSurvey
  end

  def self.getItemWeightsFromSurvey
    if Surveys::Loric.count == 0
      return nil
    end

    itemWs = []
    9.times do |i|
      itemWs.push(Surveys::Loric.average("item"+(i+1).to_s).to_f)
    end

    itemWSum = 0
    itemWs.each do |w|
      itemWSum = itemWSum + w
    end

    9.times do |i|
      itemWs[i] = (itemWs[i]/itemWSum).round(4)
    end

    itemWs
  end

end