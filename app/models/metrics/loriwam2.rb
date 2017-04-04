#LORI WAM with inferred weights (LORI WAM IW)
#Use the weights inferred from the Evaluations

class Metrics::LORIWAM2 < Metrics::WAM
  #this is for Metrics with type=LORIWAM2

  def self.itemWeights
    [
      BigDecimal(0.1475,4),
      BigDecimal(0.0665,4),
      BigDecimal(0.1383,4),
      BigDecimal(0.2427,4),
      BigDecimal(0.0054,4),
      BigDecimal(0.1324,4),
      BigDecimal(0.0899,4),
      BigDecimal(0.1084,4),
      BigDecimal(0.0689,4)
    ]
  end

end