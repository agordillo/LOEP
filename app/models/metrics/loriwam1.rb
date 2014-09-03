#LORI WAM with collected weights (LORI WAM CW)
#Use the weights obtained from the LORI survey

class Metrics::LORIWAM1 < Metrics::WAM
  # this is for Metrics with type=LORIWAM1

  def self.itemWeights
    [
      BigDecimal(0.1724,4),
      BigDecimal(0.1207,4),
      BigDecimal(0.1138,4),
      BigDecimal(0.1414,4),
      BigDecimal(0.1379,4),
      BigDecimal(0.1034,4),
      BigDecimal(0.0655,4),
      BigDecimal(0.0759,4),
      BigDecimal(0.069,4)
    ]
  end

end