#Arithmetic mean of LORI items.
#All items have the same importance (same weight)

class Metrics::LORIAM < Metrics::LORIWAM
  # this is for Metrics with type=LORIAM

  def self.itemWeights
    [
      # BigDecimal('1/9'),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6),
      BigDecimal(0.111111,6)
    ]
  end

end