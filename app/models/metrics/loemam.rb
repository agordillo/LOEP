#LOEM Arithmetic Mean (LOEM AM)
#Arithmetic mean of all LOEM items.
#All items have the same importance (same weight)

class Metrics::LOEMAM < Metrics::WAM
  # this is for Metrics with type=LOEMAM

  def self.itemWeights
    #This is the default behaviour
    super
  end

end