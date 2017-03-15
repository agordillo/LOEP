# encoding: utf-8

#Metadata Quality Metric: Consistency

# Type of rules
# A: All included fields are defined in the standard. / All fields that the community sets as mandatory are included.
# B: Categorical fields only contain values from a fixed list.
# C: Combination of values in categorical fields are consistent.

class Metrics::LomMetadataConsistency < Metrics::LomMetadataItem

  def self.getScoreForMetadata(lomMetadataJSON,options={})
    score = 0
    return score if options[:metadata_record].blank?
    return score if options[:metadata_record].schema != Metadata::Lom.schema

    originalMetadataJSON = options[:metadata_record].getMetadata({:schema => "original", :format => "json"})
    return score if originalMetadataJSON.blank? or originalMetadataJSON["lom"].blank?
    originalMetadataJSON = originalMetadataJSON["lom"]

    metadataFields = Metadata::Lom.metadata_fields_from_json(lomMetadataJSON) rescue {}
    return score if metadataFields.blank?

    rules = []
    weights = ruleWeights

    # A Rules
    # Rule 1. All included fields are defined in the LOM standard.
    rules.push(Metadata::Lom.getElements(originalMetadataJSON,{"lomcompliant"=>false}).length === 0)
    
    # B Rules
    # Rule 2. All mandatory fields are included. Mandatory fields: identifier and title.
    rules.push(!(metadataFields["1.1.1"].blank? or metadataFields["1.1.2"].blank? or metadataFields["1.2"].blank?))

    # C Rules
    # Rule 3. Categorical fields only contain values that belong to the LOM vocabulary.
    rules.push(Metadata::Lom.getElements(lomMetadataJSON,{"datatype"=>"Vocabulary","valid"=>false}).length === 0)

    # D Rules. Combination of values in categorical fields are consistent.
    # Rule 4. Structure and Aggregation level
    unless metadataFields["1.7"].blank? or metadataFields["1.8"].blank?
      rules.push(!((metadataFields["1.7"]=="atomic" and metadataFields["1.8"]!="1") or (metadataFields["1.8"]=="1" and metadataFields["1.7"]!="atomic")))
    else
      rules.push(true)
    end
    # Rule 5. Context and Typical Age Range
    unless metadataFields["5.6"].blank? or metadataFields["5.7"].blank?
      parsedAgeRange = getAgeRange(metadataFields["5.7"])
      rules.push(!(metadataFields["5.6"]=="higher education" and (!parsedAgeRange.is_a? Numeric or parsedAgeRange < 17)))
    else
      rules.push(true)
    end

    rules.each_with_index do |rule,index|
      if(rule===true)
        score += weights[index]
      end
    end

    ([[score*10,0].max,10].min).round(2)
  end

  def self.ruleWeights
    ruleWeights = []

    ruleWeights << BigDecimal(0.25,6)
    ruleWeights << BigDecimal(0.25,6)
    ruleWeights << BigDecimal(0.25,6)

    weightForCRules = BigDecimal(0.25,6)
    nCRules = 2
    nCRules.times do |i|
      ruleWeights << BigDecimal(weightForCRules/nCRules,6)
    end
    
    ruleWeights
  end

  def self.getAgeRange(ageRange)
    #Possible values: "7-9","0-5","15","18-","suitable for childrens over 7"
    return ageRange if ageRange.is_a? Numeric
    return nil unless ageRange.is_a? String
    ages = ageRange.scan(/\d+/).map{|n| Integer(n) rescue nil}.compact
    return nil if ages.blank?
    (ages.sum.to_f/ages.size).round(0)
  end

end