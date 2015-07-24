#Metadata Quality Metric: Completeness

class Metrics::LomMetadataCompleteness < Metrics::LomMetadata

  def getScoreForLo(lo)
    self.class.getScoreForLo(lo)
  end

  def self.getScoreForLo(lo)
    metadataFields = lo.getMetadata({:schema => "LOMv1.0", :format => "json", :fields => true})
    return getScoreForMetadata(metadataFields)
  end

  def self.getScoreForMetadata(metadataFields)
    score = 0
    fieldWeights = Metrics::LomMetadata.fieldWeights
    unless metadataFields.blank?
      metadataFields.each do |key, value|
        unless value.blank?
          score += fieldWeights[key]
        end
      end
    end
    score *= 10
    return score
  end

end