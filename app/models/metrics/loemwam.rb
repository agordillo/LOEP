#LOEM Weighted Arithmetic Mean (LOEM WAM)
#Weighted Arithmetic Mean of LOEM items.

class Metrics::LOEMWAM < Metrics::WAM
  # this is for Metrics with type=LOEMWAM

  def self.getScale
    return [1,3]
  end

end