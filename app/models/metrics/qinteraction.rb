# Quality Metric based on user interactions

class Metrics::Qinteraction < Metrics::WAM
  # this is for Metrics with type=Qinteraction
  #Override methods here

  def self.getLoScore(evData)
    super
  end

  def self.itemWeights
    [
      0.303,
      0.435,
      0.262
    ]
  end

end