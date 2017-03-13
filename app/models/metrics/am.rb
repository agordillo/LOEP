# encoding: utf-8

#Generic Arithmetic Mean Metric for metrics that use multiple evaluation models
#The aim of this class is to facilitate the creation of specific Arithmetic Mean Metrics that use multiple evaluation models

class Metrics::AM < Metric
  #this is for Metrics with type=AM
  #Override methods here

  def self.getLoScore(evData)
    loScore = 0

    evMethods = self.getInstance.evmethods
    evMethods.each do |evmethod|
      loScoreForEvMethod = 0
      evData = evData[evmethod.name]
      items = evData[:items]
      itemWeight = 1/items.length.to_f
      scale = evmethod.module.constantize.getScale
      items.each_with_index do |iScore,i|
        loScoreForEvMethod += ((iScore-scale[0]) * itemWeight)
      end
      loScoreForEvMethod = 10/(scale[1]-scale[0]).to_f * loScoreForEvMethod.to_f
      loScore += loScoreForEvMethod
    end

    loScore = loScore/evMethods.length
    return loScore
  end

end