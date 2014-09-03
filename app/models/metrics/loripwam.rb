#LORI Pedagogical WAM
#Weighted Arithmetic Mean of Pedagogical LORI items.

class Metrics::LORIPWAM < Metrics::WAM
  # this is for Metrics with type=LORIPWAM

  def self.itemWeights
    [
      BigDecimal(0.2183,4),
      BigDecimal(0.1529,4),
      BigDecimal(0.1441,4),
      BigDecimal(0.1791,4),
      BigDecimal(0.1746,4),
      BigDecimal(0.1310,4),
      BigDecimal(0,4),
      BigDecimal(0,4),
      BigDecimal(0,4)
    ]
  end

end