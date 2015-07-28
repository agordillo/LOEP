# encoding: utf-8

#Metadata Quality Metric: Consistency

# Type of rules
# A: All included fields are defined in the standard. / All fields that the community sets as mandatory are included.
# B: Categorical fields only contain values from a fixed list.
# C: Combination of values in categorical fields are consistent.

class Metrics::LomMetadataConsistency < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    return score if metadataJSON.blank?

    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    rules = []
    weights = ruleWeights

    # A Rules
    #Rule 1. All included fields are defined in the standard.
    rules.push(Metadata::Lom.getElements(metadataJSON,{"lomcompliant"=>false}).length === 0)
    #Rule 2. All mandatory fields are included. Mandatory fields: identifier and title.
    rules.push(!(metadataFields["1.1.1"].blank? and metadataFields["1.1.2"].blank? and metadataFields["1.2"].blank?))

    # B Rules. Categorical fields only contain values from a fixed list.
    rules.push(Metadata::Lom.getElements(metadataJSON,{"datatype"=>"Vocabulary","valid"=>false}).length === 0)

    rules.each_with_index do |rule,index|
      if(rule===true)
        score += weights[index]
      end
    end

    # score = [1,[0,score].max].min
    score *= 10
    return score
  end

  def self.ruleWeights
    ruleWeights = []

    ruleWeights << BigDecimal(0.5,6)
    ruleWeights << BigDecimal(0.5,6)
    ruleWeights << BigDecimal(0.5,6)

    ruleWeights
  end 


end