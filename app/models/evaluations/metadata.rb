# encoding: utf-8

class Evaluations::Metadata < Evaluation
  # this is for Evaluations with evMethod=Metadata Quality (type=MetadataEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("Metadata Quality").id
    super
  end

  def self.getItems
    [
      { :name => "Completeness",
        :description => "Degree to which the metadata instance contains all the information needed to have a comprehensive representation of the described resource.", 
        :type=> "decimal" },
        { :name => "Conformance",
        :description => "Conformance to expectations measures the degree to which the metadata instance fulfills the requirements of a given community of users for a given task.",
        :type=> "decimal" },
      { :name => "Consistency",
        :description => "Degree to which the metadata instance matches the metadata standard definition.", 
        :type=> "decimal" },
      { :name => "Coherence",
        :description => "Degree to which all the fields of the metadata instance describe the same object in a similar way.",
        :type=> "decimal" },
      { :name => "Findability",
        :description => "The level to which a metadata instance can be found.",
        :type=> "decimal" }
    ]
  end

  
  def self.getScale
    return [0,10]
  end


  ##################
  # Method to calculate the scores automatically
  ##################

  def self.createAutomaticEvaluation(lo)
    evaluation = super
    evaluation.ditem1 = Metrics::LomMetadataCompleteness.getScoreForLo(lo)
    evaluation.ditem2 = Metrics::LomMetadataConformance.getScoreForLo(lo)
    evaluation.ditem3 = Metrics::LomMetadataConsistency.getScoreForLo(lo)
    evaluation.ditem4 = Metrics::LomMetadataCoherence.getScoreForLo(lo)
    evaluation.ditem5 = Metrics::LomMetadataFindability.getScoreForLo(lo)
    evaluation.save!
    evaluation
  end

  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super(lo,Metric.find_by_type("Metrics::LomMetadata"))
  end

  def self.representationDataForLos(los)
    super
  end

  def self.representationDataForComparingLos(los)
    super
  end

end