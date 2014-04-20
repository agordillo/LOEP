#Technological Weighted Arithmetic Mean of LORI items.

class Metrics::LORITWAM < Metrics::LORIWAM
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