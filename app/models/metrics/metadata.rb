#Metadata Quality Metric

class Metrics::Metadata < Metric
  # this is for Metrics with type=Metadata
  #Override methods here

  def self.getLoScore(evData)
    return 10
  end

end