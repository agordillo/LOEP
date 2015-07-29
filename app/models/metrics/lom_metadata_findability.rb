# encoding: utf-8

#Metadata Quality Metric: Findability

class Metrics::LomMetadataFindability < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    score = getScoreForKeywords(metadataFields["1.5"],options)
    score *= 10
    return score
  end

  def self.getScoreForKeywords(keywords,options={})
    return 0 if keywords.nil?
    keywords = keywords.split(", ") if keywords.is_a? String
    return 0 unless keywords.is_a? Array

    links = MetadataGraphLink.getLinksForKeywords(keywords,options)
    maxLink = MetadataField.getMax("metadataGraphLink",options)

    [links.to_f/maxLink,1].min
  end

end