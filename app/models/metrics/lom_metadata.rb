# LOM Metadata Quality Metric

class Metrics::LomMetadata < Metrics::WAM
  # this is for Metrics with type=Metadata
  #Override methods here

  def self.getLoScore(evData)
    super
  end

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    items = []
    items.push(Metrics::LomMetadataCompleteness.getScoreForMetadata(metadataJSON,options))
    items.push(Metrics::LomMetadataConformance.getScoreForMetadata(metadataJSON,options))
    items.push(Metrics::LomMetadataConsistency.getScoreForMetadata(metadataJSON,options))
    items.push(Metrics::LomMetadataCoherence.getScoreForMetadata(metadataJSON,options))
    items.push(Metrics::LomMetadataFindability.getScoreForMetadata(metadataJSON,options))
    items.each_with_index do |value,index|
        score += value * itemWeights[index]
    end
    [0,[10,score].min].max
  end

  def self.itemWeights
    itemWeights = []
    nItems = self.getInstance.evmethods.first.getEvaluationModule.getItems.length
    nItems.times do
      itemWeights << BigDecimal(1/nItems.to_f,6)
    end
    itemWeights
  end

end