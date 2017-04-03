# encoding: utf-8

#Metadata Quality Metric: Coherence

class Metrics::LomMetadataCoherence < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    metadataTextFields = {"1.2" => metadataFields["1.2"], "1.4" => metadataFields["1.4"]}
    score = getScoreForFreeTextMetadataFields(metadataTextFields,options)
    ([[score*10,0].max,10].min).round(2)
  end

  def self.getScoreForFreeTextMetadataFields(metadataTextFields,options={})
    score = 0
    
    n = metadataTextFields.keys.length
    return 0 if n==0
    return 1 if n==1

    for i in 0..n-1
      for j in 0..n-1
        if i<j
          keyA = metadataTextFields.keys[i]
          keyB = metadataTextFields.keys[j]
          score += UtilsTfidf.getSemanticSimilarity(metadataTextFields[keyA],metadataTextFields[keyB],options.merge({:words => "min"}))
        end
      end
    end
    (score/(n*(n-1)/2))
  end

end