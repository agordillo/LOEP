# encoding: utf-8

#Metadata Quality Metric: Conformance

class Metrics::LomMetadataConformance < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    return 0 if metadataFields.blank?
    fieldWeights = Metrics::LomMetadataConformance.fieldWeights
    conformanceItems = Metrics::LomMetadataConformance.conformanceItems

    metadataFields.each do |key, value|
      unless value.blank? or conformanceItems[key].blank?
        score += getScoreForMetadataField(key,value,options) * fieldWeights[key]
      end
    end

    score * 10
  end

  def self.getScoreForMetadataField(key,value,options={})
    score = 0
    case Metrics::LomMetadataConformance.conformanceItems[key][:type]
    when "freetext"
      score = getScoreForFreeTextMetadataField(key,value,options)
    when "categorical"
      score = getScoreForCategoricalMetadataField(key,value,options)
    end
    [0,[score,1].min].max
  end

  def self.getScoreForFreeTextMetadataField(key,value,options={})
    score = UtilsTfidf.TFIDFFreeText(value,options.merge({:key => key}))
    return 0 if score==0
    [0,[Math.log(score)/(LOEP::Application::config.metadata_fields_max[key].to_f),1].min].max
  end

  def self.getScoreForCategoricalMetadataField(key,value,options={})
    n = (LOEP::Application::config.categorical_fields[options[:repository]][key + "_total"] || 1) rescue 1
    times = (LOEP::Application::config.categorical_fields[options[:repository]][key][value] || 0) rescue 0
    (1 - (Math.log(1+times)/Math.log(1+n)))
  end

  def self.conformanceItems
    {
      "1.1.2" =>  {type: "freetext"},
      "1.2" =>    {type: "freetext"},
      "1.3" =>    {type: "categorical"},
      "1.4" =>    {type: "freetext"},
      "1.5" =>    {type: "freetext"}
    }
  end

  def self.fieldWeights
    fieldWeights = {}

    fieldWeights["1.1.1"] = BigDecimal(0,6)
    fieldWeights["1.1.2"] = BigDecimal(0.2,6)
    fieldWeights["1.2"] = BigDecimal(0.25,6)
    fieldWeights["1.3"] = BigDecimal(0.15,6)
    fieldWeights["1.4"] = BigDecimal(0.2,6)
    fieldWeights["1.5"] = BigDecimal(0.2,6)
    fieldWeights["1.6"] = BigDecimal(0,6)
    fieldWeights["1.7"] = BigDecimal(0,6)
    fieldWeights["1.8"] = BigDecimal(0,6)

    fieldWeights["2.1"] = BigDecimal(0,6)
    fieldWeights["2.2"] = BigDecimal(0,6)
    fieldWeights["2.3.1"] = BigDecimal(0,6)
    fieldWeights["2.3.2"] = BigDecimal(0,6)
    fieldWeights["2.3.3"] = BigDecimal(0,6)

    fieldWeights["3.1.1"] = BigDecimal(0,6)
    fieldWeights["3.1.2"] = BigDecimal(0,6)
    fieldWeights["3.2.1"] = BigDecimal(0,6)
    fieldWeights["3.2.2"] = BigDecimal(0,6)
    fieldWeights["3.2.3"] = BigDecimal(0,6)
    fieldWeights["3.3"] = BigDecimal(0,6)
    fieldWeights["3.4"] = BigDecimal(0,6)

    fieldWeights["4.1"] = BigDecimal(0,6)
    fieldWeights["4.2"] = BigDecimal(0,6)
    fieldWeights["4.3"] = BigDecimal(0,6)
    fieldWeights["4.4.1.1"] = BigDecimal(0,6)
    fieldWeights["4.4.1.2"] = BigDecimal(0,6)
    fieldWeights["4.4.1.3"] = BigDecimal(0,6)
    fieldWeights["4.4.1.4"] = BigDecimal(0,6)
    fieldWeights["4.5"] = BigDecimal(0,6)
    fieldWeights["4.6"] = BigDecimal(0,6)
    fieldWeights["4.7"] = BigDecimal(0,6)

    fieldWeights["5.1"] = BigDecimal(0,6)
    fieldWeights["5.2"] = BigDecimal(0,6)
    fieldWeights["5.3"] = BigDecimal(0,6)
    fieldWeights["5.4"] = BigDecimal(0,6)

    fieldWeights["5.5"] = BigDecimal(0,6)
    fieldWeights["5.6"] = BigDecimal(0,6)
    fieldWeights["5.7"] = BigDecimal(0,6)
    fieldWeights["5.8"] = BigDecimal(0,6)
    fieldWeights["5.9"] = BigDecimal(0,6)
    fieldWeights["5.10"] = BigDecimal(0,6)
    fieldWeights["5.11"] = BigDecimal(0,6)

    fieldWeights["6.1"] = BigDecimal(0,6)
    fieldWeights["6.2"] = BigDecimal(0,6)
    fieldWeights["6.3"] = BigDecimal(0,6)

    fieldWeights["7.1"] = BigDecimal(0,6)
    fieldWeights["7.2.1.1"] = BigDecimal(0,6)
    fieldWeights["7.2.1.2"] = BigDecimal(0,6)
    fieldWeights["7.2.2"] = BigDecimal(0,6)

    fieldWeights["8.1"] = BigDecimal(0,6)
    fieldWeights["8.2"] = BigDecimal(0,6)
    fieldWeights["8.3"] = BigDecimal(0,6)

    fieldWeights["9.1"] = BigDecimal(0,6)
    fieldWeights["9.2.1"] = BigDecimal(0,6)
    fieldWeights["9.2.2.1"] = BigDecimal(0,6)
    fieldWeights["9.2.2.2"] = BigDecimal(0,6)
    fieldWeights["9.3"] = BigDecimal(0,6)
    fieldWeights["9.4"] = BigDecimal(0,6)

    fieldWeights
  end

end