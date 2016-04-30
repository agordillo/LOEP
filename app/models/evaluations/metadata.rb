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
      { :name => I18n.t("evmethods.metadata.item1.name"),
        :description => I18n.t("evmethods.metadata.item1.description"),
        :type=> "decimal",
        :metric =>  "Metrics::LomMetadataCompleteness"
      },{ 
        :name => I18n.t("evmethods.metadata.item2.name"),
        :description => I18n.t("evmethods.metadata.item2.description"),
        :type=> "decimal",
        :metric =>  "Metrics::LomMetadataConformance"
      },{ 
        :name => I18n.t("evmethods.metadata.item3.name"),
        :description => I18n.t("evmethods.metadata.item3.description"),
        :type=> "decimal",
        :metric =>  "Metrics::LomMetadataConsistency"
      },{ 
        :name => I18n.t("evmethods.metadata.item4.name"),
        :description => I18n.t("evmethods.metadata.item4.description"),
        :type=> "decimal",
        :metric =>  "Metrics::LomMetadataCoherence"
      },{ 
        :name => I18n.t("evmethods.metadata.item5.name"),
        :description => I18n.t("evmethods.metadata.item5.description"),
        :type=> "decimal",
        :metric =>  "Metrics::LomMetadataFindability"
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

end