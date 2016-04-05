# encoding: utf-8

class Metrics::SUSG < Metric
  #this is for Metrics with type=SUSG

  def self.getLoScore(evData)
    loScore = 0

    evmethod = self.getInstance.evmethods.first
    evData = evData[evmethod.name]
    items = evData[:items]
    scale = evmethod.module.constantize.getScale

    items.each_with_index do |iScore,i|
      if ((i+1)%2!=0)
        #odd items (1,3,5,7 and 9)
        loScore += ((iScore-scale[0]))
      else
        #even items (2,4,6,8 and 10)
        loScore += ((scale[1]-iScore))
      end
    end
    loScore = 1/(scale[1]-scale[0]).to_f * loScore.to_f

    return loScore
  end
end