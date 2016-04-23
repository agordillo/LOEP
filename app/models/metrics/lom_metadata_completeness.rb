# encoding: utf-8

#Metadata Quality Metric: Completeness

class Metrics::LomMetadataCompleteness < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    fieldWeights = Metrics::LomMetadataCompleteness.fieldWeights
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    unless metadataFields.blank?
      metadataFields.each do |key, value|
        unless value.blank?
          score += fieldWeights[key]
        end
      end
    end
    ([[score*10,0].max,10].min).round(2)
  end

  def self.fieldWeights
    fieldWeights = {}

    fieldWeights["1.1.1"] = BigDecimal(0.018226,6)
    fieldWeights["1.1.2"] = BigDecimal(0.036452,6)
    fieldWeights["1.2"] = BigDecimal(0.060753,6)
    fieldWeights["1.3"] = BigDecimal(0.049819,6)
    fieldWeights["1.4"] = BigDecimal(0.042527,6)
    fieldWeights["1.5"] = BigDecimal(0.049818,6)
    fieldWeights["1.6"] = BigDecimal(0.009721,6)
    fieldWeights["1.7"] = BigDecimal(0.015796,6)
    fieldWeights["1.8"] = BigDecimal(0.014581,6)

    fieldWeights["2.1"] = BigDecimal(0.008505,6)
    fieldWeights["2.2"] = BigDecimal(0.020656,6)
    fieldWeights["2.3.1"] = BigDecimal(0.012151,6)
    fieldWeights["2.3.2"] = BigDecimal(0.021871,6)
    fieldWeights["2.3.3"] = BigDecimal(0.014581,6)

    fieldWeights["3.1.1"] = BigDecimal(0.006075,6)
    fieldWeights["3.1.2"] = BigDecimal(0.006075,6)
    fieldWeights["3.2.1"] = BigDecimal(0.003645,6)
    fieldWeights["3.2.2"] = BigDecimal(0.002430,6)
    fieldWeights["3.2.3"] = BigDecimal(0,6)
    fieldWeights["3.3"] = BigDecimal(0.014581,6)
    fieldWeights["3.4"] = BigDecimal(0.003645,6)

    fieldWeights["4.1"] = BigDecimal(0.034022,6)
    fieldWeights["4.2"] = BigDecimal(0.017011,6)
    fieldWeights["4.3"] = BigDecimal(0.027947,6)
    fieldWeights["4.4.1.1"] = BigDecimal(0.013366,6)
    fieldWeights["4.4.1.2"] = BigDecimal(0.007290,6)
    fieldWeights["4.4.1.3"] = BigDecimal(0,6)
    fieldWeights["4.4.1.4"] = BigDecimal(0,6)
    fieldWeights["4.5"] = BigDecimal(0.002430,6)
    fieldWeights["4.6"] = BigDecimal(0.009721,6)
    fieldWeights["4.7"] = BigDecimal(0.012151,6)

    fieldWeights["5.1"] = BigDecimal(0.018226,6)
    fieldWeights["5.2"] = BigDecimal(0.037667,6)
    fieldWeights["5.3"] = BigDecimal(0.009721,6)
    fieldWeights["5.4"] = BigDecimal(0.006075,6)

    fieldWeights["5.5"] = BigDecimal(0.029162,6)
    fieldWeights["5.6"] = BigDecimal(0.031592,6)
    fieldWeights["5.7"] = BigDecimal(0.037667,6)
    fieldWeights["5.8"] = BigDecimal(0.034022,6)
    fieldWeights["5.9"] = BigDecimal(0.047388,6)
    fieldWeights["5.10"] = BigDecimal(0.019441,6)
    fieldWeights["5.11"] = BigDecimal(0.010936,6)

    fieldWeights["6.1"] = BigDecimal(0.044957,6)
    fieldWeights["6.2"] = BigDecimal(0.025516,6)
    fieldWeights["6.3"] = BigDecimal(0.023086,6)

    fieldWeights["7.1"] = BigDecimal(0.009721,6)
    fieldWeights["7.2.1.1"] = BigDecimal(0.007290,6)
    fieldWeights["7.2.1.2"] = BigDecimal(0.012151,6)
    fieldWeights["7.2.2"] = BigDecimal(0.008505,6)

    fieldWeights["8.1"] = BigDecimal(0.004860,6)
    fieldWeights["8.2"] = BigDecimal(0.004860,6)
    fieldWeights["8.3"] = BigDecimal(0.013366,6)

    fieldWeights["9.1"] = BigDecimal(0,6)
    fieldWeights["9.2.1"] = BigDecimal(0.007290,6)
    fieldWeights["9.2.2.1"] = BigDecimal(0.006075,6)
    fieldWeights["9.2.2.2"] = BigDecimal(0.006075,6)
    fieldWeights["9.3"] = BigDecimal(0,6)
    fieldWeights["9.4"] = BigDecimal(0.008505,6)

    fieldWeights
  end

end