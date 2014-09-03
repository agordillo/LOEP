#LORI Weighted Arithmetic Mean (LORI WAM)
#Weighted Arithmetic Mean of LORI items.

class Metrics::LORIWAM < Metrics::WAM
  # this is for Metrics with type=LORIWAM

  def self.getScale
    return [1,5]
  end

end