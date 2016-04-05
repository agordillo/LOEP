# encoding: utf-8

#Generic Weighted Arithmetic Mean Metric
#The aim of this class is to facilitate the creation of specific Weighted Arithmetic Mean Metrics

class Metrics::WAM < Metric
  #this is for Metrics with type=WAM
  #Override methods here

  def self.getLoScore(evData)
    evmethod = self.getInstance.evmethods.first
    evData = evData[evmethod.name]
    items = evData[:items]
    scale = evmethod.module.constantize.getScale

    loScore = 0
    items.each_with_index do |iScore,i|
      loScore = loScore + ((iScore-scale[0]) * itemWeights[i])
    end
    loScore = 10/(scale[1]-scale[0]).to_f * loScore.to_f

    return loScore
  end

  #If you want to implement this class, you just need to implement and override this method
  def self.itemWeights
    #Default behaviour: Arithmetic Mean. Override with your weights array if you want to change the default behaviour.
    super
  end

end