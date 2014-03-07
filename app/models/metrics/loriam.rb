#Arithmetic mean of LORI items.
#All items have the same importance (same weight)

class Metrics::LORIAM < Metrics::LORIWAM
  # this is for Metrics with type=LORIAM

  def self.itemWeights
    [
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f,
      1/9.to_f
    ]
  end

end