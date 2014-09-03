#LORI Technological WAM
#Weighted Arithmetic Mean of LORI items related to technology.

class Metrics::LORITWAM < Metrics::WAM
  # this is for Metrics with type=LORITWAM

  def self.itemWeights
    [
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0.3113,4),
      BigDecimal(0.3607,4),
      BigDecimal(0.3280,4)
    ]
  end

end