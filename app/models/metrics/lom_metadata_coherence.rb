# encoding: utf-8

#Metadata Quality Metric: Coherence

class Metrics::LomMetadataCoherence < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    metadataTextFields = {"1.2" => metadataFields["1.2"], "1.4" => metadataFields["1.4"]}
    score = getScoreForFreeTextMetadataFields(metadataTextFields,options)
    score *= 10
    return score
  end

  def self.semanticDistance(textA,textB,options={})
    return 0 if (textA.blank? or textB.blank?)

    numerator = 0
    denominator = 0
    denominatorA = 0
    denominatorB = 0

    # words = Metrics::LomMetadataConformance.processFreeText(textA).merge(Metrics::LomMetadataConformance.processFreeText(textB)).keys
    words = [Metrics::LomMetadataConformance.processFreeText(textA).keys, Metrics::LomMetadataConformance.processFreeText(textB).keys].sort_by{|words| words.length}.first

    words.each do |word|
      tfidf1 = Metrics::LomMetadataConformance.TFIDF(word,textA,options)
      tfidf2 = Metrics::LomMetadataConformance.TFIDF(word,textB,options)
      numerator += (tfidf1 * tfidf2)
      denominatorA += tfidf1**2
      denominatorB += tfidf2**2
    end

    denominator = Math.sqrt(denominatorA * denominatorB)
    return 0 if denominator==0
    numerator/denominator
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
          score += semanticDistance(metadataTextFields[keyA],metadataTextFields[keyB],options.merge({:key => [keyA,keyB]}))
        end
      end
    end
    score = (score/(n*(n-1)/2))
  end

end