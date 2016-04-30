# encoding: utf-8

class Evaluations::Qinteraction < Evaluation
  # this is for Evaluations with evMethod=QInteraction (type=QinteractionEvaluation)

  def init
    self.evmethod_id ||= Evmethod.find_by_name("Interaction Quality").id
    super
  end

  def self.getItems
    [
      { :name => "Time Spent",
        :description => "Average time spent by the users in the Learning Object.", 
        :type=> "decimal",
        :metric =>  "Metrics::QinteractionTime"
      },{ 
        :name => "Permanency Rate",
        :description => "Percentage of users that do not abandon the Learning Object after a few seconds.",
        :type=> "decimal",
        :metric =>  "Metrics::QinteractionPermanency"
      },{ 
        :name => "Clicks Frequency",
        :description => "Average number of performed clicks per time unit.", 
        :type=> "decimal",
        :metric =>  "Metrics::QinteractionClickFrequency"
      }
    ]
  end

  def self.getScale
    return [0,10]
  end


  ##################
  # Method to calculate the scores automatically
  ##################

  def self.createAutomaticEvaluation(lo)
    return nil if lo.lo_interaction.nil?
    evaluation = super
    evaluation.ditem1 = Metrics::QinteractionTime.getScoreForLo(lo)
    evaluation.ditem2 = Metrics::QinteractionPermanency.getScoreForLo(lo)
    evaluation.ditem3 = Metrics::QinteractionClickFrequency.getScoreForLo(lo)
    evaluation.save!
    evaluation
  end


  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super(lo,Metric.find_by_type("Metrics::Qinteraction"))
  end

end