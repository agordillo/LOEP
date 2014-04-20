#Weighted arithmetic mean of LORI items.
#Use the weights inferred from Evaluations

class Metrics::LORIWAM2 < Metrics::LORIWAM
  # this is for Metrics with type=LORIWAM2

  def self.itemWeights
    [
      BigDecimal(0.1475,4),
      BigDecimal(0.0665,4),
      BigDecimal(0.1381,4),
      BigDecimal(0.2424,4),
      BigDecimal(0.0052,4),
      BigDecimal(0.1322,4),
      BigDecimal(0.0901,4),
      BigDecimal(0.1090,4),
      BigDecimal(0.069,4)
    ]
  end

end