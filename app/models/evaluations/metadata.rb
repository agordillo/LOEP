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
        { :name => "Completeness2",
        :description => "Degree to which the metadata instance contains all the information needed to have a comprehensive representation of the described resource.", 
        :type=> "decimal" },
      { :name => "Completeness3",
        :description => "Degree to which the metadata instance contains all the information needed to have a comprehensive representation of the described resource.", 
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
    evaluation.ditem2 = Metrics::LomMetadataCompleteness.getScoreForLo(lo)
    evaluation.ditem3 = Metrics::LomMetadataCompleteness.getScoreForLo(lo)
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