#Metric combinining LORI and LOEM methods. 50%LORI,50%LOEM

class Metrics::LORIEM < Metric
  # this is for Metrics with type=LORIEM
  #Override methods here

  def self.getLoScore(evData)
    the_LORI_score = Metrics::LORIAM.getLoScore(evData)
    the_LOEM_score = Metrics::LOEMAM.getLoScore(evData)

    if the_LORI_score.nil? or the_LOEM_score.nil?
      return nil
    end
    
    loScore = 0.5*the_LORI_score+0.5*the_LOEM_score

    return loScore
  end

end